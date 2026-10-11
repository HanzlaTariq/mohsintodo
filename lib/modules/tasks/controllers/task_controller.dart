import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/task_model.dart';
import '../../../data/services/task_service.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../home/controllers/home_controller.dart';

class TaskController extends GetxController {
  final TaskService _taskService = Get.find<TaskService>();

  HomeController get _home => Get.find<HomeController>();

  // Form state
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController();
  final Rx<DateTime?> dueDate = Rx<DateTime?>(null);
  final RxString priority = 'Medium'.obs;
  final RxBool isSaving = false.obs;
  final Rx<TaskModel?> editing = Rx<TaskModel?>(null);

  // Details state
  final RxString selectedId = ''.obs;

  bool get isEditing => editing.value != null;

  TaskModel? get selectedTask =>
      _home.tasks.firstWhereOrNull((t) => t.id == selectedId.value);

  // ---------- Navigation helpers ----------

  void openAdd() {
    _resetForm();
    Get.toNamed(Routes.addEditTask);
  }

  void openEdit(TaskModel task) {
    editing.value = task;
    titleCtrl.text = task.title;
    descCtrl.text = task.description;
    dueDate.value = task.dueDate;
    dateCtrl.text = _formatDate(task.dueDate);
    priority.value = task.priority;
    Get.toNamed(Routes.addEditTask);
  }

  void openDetails(TaskModel task) {
    selectedId.value = task.id;
    Get.toNamed(Routes.taskDetails);
  }

  void _resetForm() {
    editing.value = null;
    titleCtrl.clear();
    descCtrl.clear();
    dateCtrl.clear();
    dueDate.value = null;
    priority.value = 'Medium';
  }

  String _formatDate(DateTime date) => DateFormat('EEE, d MMM yyyy').format(date);

  // ---------- Form actions ----------

  void setPriority(String value) => priority.value = value;

  Future<void> pickDate() async {
    final BuildContext? context = Get.context;
    if (context == null) return;
    final DateTime now = DateTime.now();
    final DateTime initial = dueDate.value ?? now;
    final DateTime first = DateTime(now.year - 1, 1, 1);
    final DateTime last = DateTime(now.year + 5, 12, 31);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? now : initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      final DateTime onlyDate = DateTime(picked.year, picked.month, picked.day);
      dueDate.value = onlyDate;
      dateCtrl.text = _formatDate(onlyDate);
    }
  }

  Future<void> save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    final DateTime? due = dueDate.value;
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (due == null || uid == null) {
      AppSnack.error(AppStrings.genericError);
      return;
    }

    isSaving.value = true;
    final bool wasEditing = isEditing;
    try {
      if (wasEditing) {
        final TaskModel updated = editing.value!.copyWith(
          title: titleCtrl.text.trim(),
          description: descCtrl.text.trim(),
          dueDate: due,
          priority: priority.value,
        );
        await _taskService.updateTask(updated).timeout(const Duration(seconds: 15));
      } else {
        final TaskModel task = TaskModel(
          id: '',
          userId: uid,
          title: titleCtrl.text.trim(),
          description: descCtrl.text.trim(),
          dueDate: due,
          priority: priority.value,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        await _taskService.addTask(task).timeout(const Duration(seconds: 15));
      }
      Get.back();
      AppSnack.success(wasEditing ? 'Task updated' : 'Task added');
    } on TimeoutException {
      Get.back();
      AppSnack.info('You seem offline. Your task will sync when you reconnect.');
    } on FirebaseException catch (e) {
      AppSnack.error(e.message ?? AppStrings.genericError);
    } catch (_) {
      AppSnack.error(AppStrings.genericError);
    } finally {
      isSaving.value = false;
    }
  }

  // ---------- Task actions ----------

  Future<bool> confirmDelete(TaskModel task) {
    return ConfirmDialog.show(
      title: AppStrings.deleteTitle,
      message: 'Are you sure you want to delete "${task.title}"? This cannot be undone.',
      confirmText: AppStrings.delete,
      icon: AppIcons.delete,
      color: const Color(0xFFEF4444),
    );
  }

  Future<void> deleteFromDetails(TaskModel task) async {
    final bool confirmed = await confirmDelete(task);
    if (!confirmed) return;
    Get.back();
    await _home.deleteTask(task);
  }

  Future<void> toggleCompleted(TaskModel task) => _home.toggleComplete(task);

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    dateCtrl.dispose();
    super.onClose();
  }
}

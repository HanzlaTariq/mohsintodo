import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_strings.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/task_model.dart';
import '../../../data/services/task_service.dart';

class HomeController extends GetxController {
  static const List<String> filters = ['All', 'Pending', 'Completed'];
  static const List<String> sortOptions = ['Due Date', 'Priority'];

  final TaskService _taskService = Get.find<TaskService>();

  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString filter = 'All'.obs;
  final RxString sortBy = 'Due Date'.obs;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<TaskModel>>? _taskSub;

  int get total => tasks.length;
  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get pendingCount => tasks.where((t) => !t.isCompleted).length;

  /// Tasks after search, filter and sort (all done on the client).
  List<TaskModel> get visibleTasks {
    final String query = searchQuery.value.trim().toLowerCase();
    final String activeFilter = filter.value;
    final String activeSort = sortBy.value;

    final List<TaskModel> result = tasks.where((t) {
      if (activeFilter == 'Pending' && t.isCompleted) return false;
      if (activeFilter == 'Completed' && !t.isCompleted) return false;
      if (query.isNotEmpty && !t.title.toLowerCase().contains(query)) return false;
      return true;
    }).toList();

    result.sort((a, b) {
      if (activeSort == 'Priority') {
        final int byPriority = b.priorityWeight.compareTo(a.priorityWeight);
        if (byPriority != 0) return byPriority;
        return a.dueDate.compareTo(b.dueDate);
      }
      final int byDate = a.dueDate.compareTo(b.dueDate);
      if (byDate != 0) return byDate;
      return b.priorityWeight.compareTo(a.priorityWeight);
    });
    return result;
  }

  @override
  void onInit() {
    super.onInit();
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    _taskSub?.cancel();
    _taskSub = null;
    tasks.clear();
    if (user == null) {
      searchQuery.value = '';
      filter.value = 'All';
      sortBy.value = 'Due Date';
      isLoading.value = false;
      return;
    }
    _listen(user.uid);
  }

  void _listen(String uid) {
    isLoading.value = true;
    errorMessage.value = '';
    _taskSub = _taskService.watchTasks(uid).listen(
      (List<TaskModel> list) {
        tasks.assignAll(list);
        isLoading.value = false;
        errorMessage.value = '';
      },
      onError: (Object error) {
        isLoading.value = false;
        errorMessage.value = error is FirebaseException
            ? (error.message ?? AppStrings.genericError)
            : AppStrings.genericError;
      },
    );
  }

  void retry() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _taskSub?.cancel();
    _listen(user.uid);
  }

  void setSearch(String value) => searchQuery.value = value;
  void setFilter(String value) => filter.value = value;
  void setSort(String? value) {
    if (value != null) sortBy.value = value;
  }

  Future<void> toggleComplete(TaskModel task) async {
    final int index = tasks.indexWhere((t) => t.id == task.id);
    if (index < 0) return;

    final TaskModel updated = task.copyWith(isCompleted: !task.isCompleted);
    tasks[index] = updated; // optimistic update for instant feedback

    try {
      await _taskService.setCompleted(task.id, updated.isCompleted);
    } catch (e) {
      final int again = tasks.indexWhere((t) => t.id == task.id);
      if (again >= 0) tasks[again] = task;
      AppSnack.error(e is FirebaseException
          ? (e.message ?? AppStrings.genericError)
          : AppStrings.genericError);
    }
  }

  Future<void> deleteTask(TaskModel task) async {
    final int index = tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) tasks.removeAt(index); // optimistic removal

    try {
      await _taskService.deleteTask(task.id);
      AppSnack.success('Task deleted');
    } catch (e) {
      final int at = index < 0 ? 0 : (index > tasks.length ? tasks.length : index);
      tasks.insert(at, task);
      AppSnack.error(e is FirebaseException
          ? (e.message ?? AppStrings.genericError)
          : AppStrings.genericError);
    }
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _taskSub?.cancel();
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_strings.dart';
import '../../../data/models/task_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../auth/controllers/validators.dart';
import '../controllers/task_controller.dart';

class AddEditTaskView extends GetView<TaskController> {
  const AddEditTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool editing = controller.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? AppStrings.editTask : AppStrings.addTask),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.sunGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(AppIcons.back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppColors.softShadow,
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: controller.titleCtrl,
                  label: AppStrings.title,
                  icon: AppIcons.title,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, 'Title'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.descCtrl,
                  label: AppStrings.description,
                  icon: AppIcons.description,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.dateCtrl,
                  label: AppStrings.dueDate,
                  hint: AppStrings.selectDate,
                  icon: AppIcons.calendar,
                  readOnly: true,
                  onTap: controller.pickDate,
                  suffix: const Icon(AppIcons.dropDown),
                  validator: (v) => Validators.required(v, 'Due date'),
                ),
                const SizedBox(height: 22),
                Text(
                  AppStrings.priority,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Row(
                    children: TaskModel.priorities.map((p) {
                      final bool last = p == TaskModel.priorities.last;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: last ? 0 : 10),
                          child: _PriorityChip(
                            label: p,
                            selected: controller.priority.value == p,
                            onTap: () => controller.setPriority(p),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 28),
                Obx(
                  () => CustomButton(
                    label: editing ? AppStrings.updateTask : AppStrings.saveTask,
                    icon: AppIcons.check,
                    isLoading: controller.isSaving.value,
                    onPressed: controller.save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = AppColors.priorityColor(label);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 50,
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color, width: 1.6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.flag, size: 18, color: selected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

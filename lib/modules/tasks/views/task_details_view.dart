import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_strings.dart';
import '../../../data/models/task_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../controllers/task_controller.dart';

class TaskDetailsView extends GetView<TaskController> {
  const TaskDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final TaskModel? task = controller.selectedTask;
        if (task == null) {
          return EmptyState(
            icon: AppIcons.search,
            title: 'Task not found',
            message: 'This task may have been deleted.',
            actionLabel: 'Go back',
            onAction: () => Get.back(),
          );
        }

        final Color color = AppColors.priorityColor(task.priority);
        final bool overdue = task.isOverdue;
        final bool done = task.isCompleted;
        final Color statusColor =
            done ? AppColors.success : (overdue ? AppColors.overdue : AppColors.medium);
        final String statusText = done ? 'Completed' : (overdue ? 'Overdue' : 'Pending');
        final IconData statusIcon =
            done ? AppIcons.done : (overdue ? AppIcons.warning : AppIcons.pending);

        return Column(
          children: [
            _buildHeader(context, task, color, statusText),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  _InfoCard(
                    icon: statusIcon,
                    label: 'Status',
                    color: statusColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusText,
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 14),
                        CustomButton(
                          label: done ? AppStrings.markPending : AppStrings.markCompleted,
                          icon: done ? AppIcons.undo : AppIcons.check,
                          height: 48,
                          onPressed: () => controller.toggleCompleted(task),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    icon: AppIcons.calendar,
                    label: AppStrings.dueDate,
                    color: overdue ? AppColors.overdue : AppColors.primary,
                    child: Text(
                      DateFormat('EEEE, d MMMM yyyy').format(task.dueDate),
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: overdue ? AppColors.overdue : AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    icon: AppIcons.description,
                    label: AppStrings.description,
                    color: AppColors.secondary,
                    child: Text(
                      task.description.trim().isEmpty
                          ? AppStrings.noDescription
                          : task.description,
                      style: GoogleFonts.nunito(
                        fontSize: 15.5,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: task.description.trim().isEmpty
                            ? AppColors.textMuted
                            : AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    icon: AppIcons.time,
                    label: 'Created',
                    color: AppColors.textMuted,
                    child: Text(
                      DateFormat('d MMM yyyy, h:mm a').format(task.createdAt),
                      style: GoogleFonts.nunito(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, TaskModel task, Color color, String statusText) {
    final double top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, top + 8, 16, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderButton(icon: AppIcons.back, onTap: () => Get.back()),
              const Spacer(),
              _HeaderButton(icon: AppIcons.edit, onTap: () => controller.openEdit(task)),
              const SizedBox(width: 10),
              _HeaderButton(
                icon: AppIcons.delete,
                onTap: () => controller.deleteFromDetails(task),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 18, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.nunito(
                    fontSize: 27,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _HeaderPill(icon: AppIcons.flag, label: '${task.priority} priority'),
                    _HeaderPill(icon: AppIcons.done, label: statusText),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.25),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 21),
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 19, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

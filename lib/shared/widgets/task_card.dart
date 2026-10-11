import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../app/constants/app_colors.dart';
import '../../app/constants/app_icons.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.confirmDelete,
    required this.onDelete,
  });

  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final Future<bool> Function() confirmDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final Color priorityColor = AppColors.priorityColor(task.priority);
    final bool overdue = task.isOverdue;
    final bool done = task.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Dismissible(
        key: ValueKey<String>(task.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => confirmDelete(),
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 26),
          decoration: BoxDecoration(
            color: AppColors.high,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(AppIcons.delete, color: Colors.white, size: 28),
              const SizedBox(height: 2),
              Text(
                'Delete',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppColors.softShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(width: 9, color: priorityColor),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: _BounceCheck(checked: done, onTap: onToggle),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.nunito(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w800,
                                        color: done ? AppColors.textMuted : AppColors.textDark,
                                        decoration: done ? TextDecoration.lineThrough : null,
                                        decorationColor: AppColors.success,
                                        decorationThickness: 2,
                                      ),
                                    ),
                                    if (task.description.trim().isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        task.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.nunito(
                                          fontSize: 13.5,
                                          color: AppColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        _Pill(
                                          icon: AppIcons.calendar,
                                          label: DateFormat('d MMM').format(task.dueDate) +
                                              (overdue ? ' • Overdue' : ''),
                                          color: overdue ? AppColors.overdue : AppColors.textMuted,
                                        ),
                                        _Pill(
                                          icon: AppIcons.flag,
                                          label: task.priority,
                                          color: priorityColor,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                done
                                    ? AppIcons.done
                                    : (overdue ? AppIcons.warning : AppIcons.time),
                                color: done
                                    ? AppColors.success
                                    : (overdue ? AppColors.overdue : AppColors.textMuted),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Round checkbox that bounces when it becomes checked.
class _BounceCheck extends StatefulWidget {
  const _BounceCheck({required this.checked, required this.onTap});

  final bool checked;
  final VoidCallback onTap;

  @override
  State<_BounceCheck> createState() => _BounceCheckState();
}

class _BounceCheckState extends State<_BounceCheck> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOut)), weight: 35),
    TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 0.88).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
    TweenSequenceItem(tween: Tween<double>(begin: 0.88, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 35),
  ]).animate(_controller);

  @override
  void didUpdateWidget(covariant _BounceCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checked != oldWidget.checked) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.checked ? AppColors.success : Colors.transparent,
            border: Border.all(
              color: widget.checked ? AppColors.success : AppColors.border,
              width: 2.4,
            ),
          ),
          child: widget.checked
              ? const Icon(AppIcons.check, size: 18, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

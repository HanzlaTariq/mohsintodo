import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_strings.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/task_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../tasks/controllers/task_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskCtrl = Get.find<TaskController>();

    return Scaffold(
      drawer: const _HomeDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: taskCtrl.openAdd,
        icon: const Icon(AppIcons.add),
        label: const Text(AppStrings.newTask),
      ),
      body: const Column(
        children: [
          _HomeHeader(),
          Expanded(child: _HomeBody()),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final HomeController home = Get.find<HomeController>();
    final AuthController auth = Get.find<AuthController>();
    final double top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.sunGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(
                builder: (ctx) => _RoundIconButton(
                  icon: AppIcons.menu,
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              const Spacer(),
              const Icon(AppIcons.sun, color: Colors.white, size: 22),
              const SizedBox(width: 6),
              Text(
                AppStrings.appName,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 44),
            ],
          ),
          const SizedBox(height: 20),
          Obx(
            () => Text(
              'Hello, ${auth.firstName} 👋',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('EEEE, d MMMM').format(DateTime.now()),
            style: GoogleFonts.nunito(
              color: Colors.white.withOpacity(0.92),
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: AppIcons.total,
                    label: AppStrings.total,
                    value: '${home.total}',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: AppIcons.done,
                    label: AppStrings.completed,
                    value: '${home.completedCount}',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: AppIcons.pending,
                    label: AppStrings.pending,
                    value: '${home.pendingCount}',
                    color: AppColors.medium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

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
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final HomeController home = Get.find<HomeController>();
    final TaskController taskCtrl = Get.find<TaskController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: CustomTextField(
            hint: AppStrings.searchHint,
            icon: AppIcons.search,
            textInputAction: TextInputAction.search,
            onChanged: home.setSearch,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: Obx(
            () => ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: HomeController.filters
                  .map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterPill(
                        label: f,
                        selected: home.filter.value == f,
                        onTap: () => home.setFilter(f),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(
            children: [
              Obx(
                () => Text(
                  '${home.visibleTasks.length} ${home.visibleTasks.length == 1 ? 'task' : 'tasks'}',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Obx(
                  () => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: home.sortBy.value,
                      isDense: true,
                      borderRadius: BorderRadius.circular(16),
                      icon: const Icon(AppIcons.sort, color: AppColors.primary, size: 20),
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                      items: HomeController.sortOptions
                          .map(
                            (s) => DropdownMenuItem<String>(
                              value: s,
                              child: Text('Sort: $s'),
                            ),
                          )
                          .toList(),
                      onChanged: home.setSort,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Obx(() {
            if (home.isLoading.value) {
              return const LoadingWidget(message: AppStrings.loadingTasks);
            }
            if (home.errorMessage.value.isNotEmpty) {
              return EmptyState(
                icon: AppIcons.error,
                title: AppStrings.errorTitle,
                message: home.errorMessage.value,
                actionLabel: AppStrings.tryAgain,
                onAction: home.retry,
              );
            }
            final items = home.visibleTasks;
            if (items.isEmpty) {
              final bool noTasksAtAll = home.tasks.isEmpty;
              return EmptyState(
                icon: noTasksAtAll ? AppIcons.emptyTasks : AppIcons.search,
                title: noTasksAtAll ? AppStrings.noTasksTitle : AppStrings.noMatchTitle,
                message: noTasksAtAll ? AppStrings.noTasksMessage : AppStrings.noMatchMessage,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final task = items[index];
                return TaskCard(
                  key: ValueKey<String>(task.id),
                  task: task,
                  onTap: () => taskCtrl.openDetails(task),
                  onToggle: () => home.toggleComplete(task),
                  confirmDelete: () => taskCtrl.confirmDelete(task),
                  onDelete: () => home.deleteTask(task),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          boxShadow: selected ? AppColors.softShadow : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer();

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();
    final TaskController taskCtrl = Get.find<TaskController>();
    final MediaQueryData mq = MediaQuery.of(context);

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, mq.padding.top + 28, 24, 28),
            decoration: const BoxDecoration(
              gradient: AppColors.sunGradient,
              borderRadius: BorderRadius.only(topRight: Radius.circular(28), bottomRight: Radius.circular(0), bottomLeft: Radius.circular(36)),
            ),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Text(
                      auth.initial,
                      style: GoogleFonts.nunito(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    auth.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    auth.userEmail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.92),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _DrawerTile(
            icon: AppIcons.home,
            label: AppStrings.myTasks,
            onTap: () => Get.back(),
          ),
          _DrawerTile(
            icon: AppIcons.add,
            label: AppStrings.newTask,
            onTap: () {
              Get.back();
              taskCtrl.openAdd();
            },
          ),
          const Spacer(),
          const Divider(indent: 24, endIndent: 24),
          _DrawerTile(
            icon: AppIcons.logout,
            label: AppStrings.logout,
            color: AppColors.high,
            onTap: auth.logout,
          ),
          SizedBox(height: mq.padding.bottom + 12),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textDark,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Icon(icon, color: color == AppColors.textDark ? AppColors.primary : color),
        title: Text(
          label,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}

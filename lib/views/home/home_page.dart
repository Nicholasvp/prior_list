import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:prior_list/controllers/home_controller.dart';
import 'package:prior_list/controllers/navigation_controller.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/views/prior_list/prior_list_page.dart';
import 'package:prior_list/widgets/buttom_sheet_item_form.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = autoInjector.get<HomeController>();
    final priorListController = autoInjector.get<PriorListController>();
    final navigationController = autoInjector.get<NavigationController>();

    return ValueListenableBuilder(
      valueListenable: navigationController.currentIndex,
      builder: (context, index, _) {
        final isTasksTab = index == 0;

        return Scaffold(
          body: _pages[index],

          /// FAB só na aba tarefas
          floatingActionButton: isTasksTab
              ? ValueListenableBuilder(
                  valueListenable: homeController.isAdding,
                  builder: (context, isAdding, child) {
                    return FloatingActionButton(
                      onPressed: () {
                        homeController.isAdding.value = !isAdding;
                        priorListController.clearForm();
                      },
                      child: HugeIcon(
                        icon: isAdding
                            ? HugeIcons.strokeRoundedRemove02
                            : HugeIcons.strokeRoundedAdd02,
                        color: Colors.black,
                      ),
                    );
                  },
                )
              : null,

          /// Bottom Navigation
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: navigationController.changeTab,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.checklist),
                label: 'Tarefas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups),
                label: 'Time',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),

          /// BottomSheet só na tab tarefas
          bottomSheet: isTasksTab
              ? ValueListenableBuilder(
                  valueListenable: homeController.isAdding,
                  builder: (context, isAdding, child) => isAdding
                      ? const BottomSheetItemForm()
                      : const SizedBox.shrink(),
                )
              : null,
        );
      },
    );
  }
}

final List<Widget> _pages = [
  const PriorListPage(),
  const Center(child: Text('Time Page')),
  const Center(child: Text('Perfil Page')),
];
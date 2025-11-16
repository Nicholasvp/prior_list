import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:prior_list/controllers/home_controller.dart';
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
    return Scaffold(
      body: PriorListPage(),
      floatingActionButton: ValueListenableBuilder(
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
      ),
      bottomSheet: ValueListenableBuilder(
        valueListenable: homeController.isAdding,
        builder: (context, isAdding, child) =>
            isAdding ? ButtomSheetItemForm() : SizedBox.shrink(),
      ),
    );
  }
}

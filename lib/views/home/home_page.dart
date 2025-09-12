import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:prior_list/controllers/home_controller.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/views/prior_list/prior_list_page.dart';
import 'package:prior_list/widgets/text_form_primary.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = autoInjector.get<HomeController>();
    return Scaffold(
      body: PriorListPage(),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: homeController.isAdding,
        builder: (context, isAdding, child) {
          return FloatingActionButton(
            onPressed: () {
              homeController.isAdding.value = !isAdding;
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
        builder: (context, isAdding, child) => isAdding
            ? BottomSheet(
                onClosing: () {},
                builder: (context) {
                  return Container(
                    constraints: BoxConstraints(maxHeight: 500, minHeight: 300),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Item',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Gap(20),
                        TextFormPrimary(
                          label: 'Name',
                          hintText: 'Enter the name',
                        ),
                        Gap(10),
                        TextFormPrimary(
                          label: 'Date',
                          hintText: 'Enter the date',
                        ),
                      ],
                    ),
                  );
                },
              )
            : SizedBox.shrink(),
      ),
    );
  }
}

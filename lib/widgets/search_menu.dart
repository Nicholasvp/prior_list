import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';

class SearchMenu extends StatelessWidget {
  final TextEditingController searchController;
  final PriorListController priorListController;
  final Function(String) onSearchChanged;
  final VoidCallback onFilterPressed;

  const SearchMenu({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterPressed,
    required this.priorListController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'search'.tr(),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedSearchCircle,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          Gap(8),
          ValueListenableBuilder<String>(
            valueListenable: priorListController.sortType,
            builder: (context, active, child) {
              return IconButton(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedFilter,
                  color: Colors.black,
                ),
                onPressed: onFilterPressed,
              );
            },
          ),
        ],
      ),
    );
  }
}
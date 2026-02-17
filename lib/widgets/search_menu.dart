import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';

class SearchMenu extends StatefulWidget {
  final TextEditingController searchController;
  final PriorListController priorListController;
  final Function(String) onSearchChanged;
  

  const SearchMenu({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    
    required this.priorListController,
  });

  @override
  State<SearchMenu> createState() => _SearchMenuState();
}

class _SearchMenuState extends State<SearchMenu> {
  void openSortModal() {
    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<String>(
          valueListenable: widget.priorListController.sortType,
          builder: (context, active, child) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Data
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedCalendar01,
                        color: active == 'date' ? Colors.blue : Colors.black,
                      ),
                      onPressed: () {
                        widget.priorListController.changeSort('date');
                        Navigator.pop(context);
                      },
                    ),
                    // Nome (alfabética)
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrangeByLettersAZ,
                        color: active == 'name' ? Colors.blue : Colors.black,
                      ),
                      onPressed: () {
                        widget.priorListController.changeSort('name');
                        Navigator.pop(context);
                      },
                    ),
                    // Prioridade
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedTemperature,
                        color: active == 'priority'
                            ? Colors.blue
                            : Colors.black,
                      ),
                      onPressed: () {
                        widget.priorListController.changeSort('priority');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.searchController,
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
              onChanged: widget.onSearchChanged,
            ),
          ),
          Gap(8),
          ValueListenableBuilder<String>(
            valueListenable: widget.priorListController.sortType,
            builder: (context, active, child) {
              return IconButton(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedFilter,
                  color: Colors.black,
                ),
                onPressed: openSortModal,
              );
            },
          ),
        ],
      ),
    );
  }
}
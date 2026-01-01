import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/views/prior_list/prior_list_builder.dart';
import 'package:prior_list/models/item_model.dart';

class PriorListPage extends StatefulWidget {
  final bool showSearch;

  const PriorListPage({super.key, this.showSearch = true});

  @override
  State<PriorListPage> createState() => _PriorListPageState();
}

class _PriorListPageState extends State<PriorListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final priorListController = autoInjector.get<PriorListController>();

  void _openSortModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar01,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    priorListController.sortItems('date');
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrangeByLettersAZ,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    priorListController.sortItems('alphabetical');
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedTemperature,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    priorListController.sortItems('priority');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    if (priorListController.items.value.isEmpty &&
        !priorListController.isLoadingNotifier.value) {
      priorListController.getList();
    }

    return SafeArea(
      child: Column(
        children: [
          if (widget.showSearch)
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
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
                      onChanged: (val) {
                        setState(() => _query = val);
                        priorListController.search(_query);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedFilter, color: Colors.black,),
                    onPressed: _openSortModal,
                  ),
                ],
              ),
            ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: priorListController.state,
              builder: (context, value, child) {
                if (priorListController.isLoadingNotifier.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (priorListController.hasErrorNotifier.value) {
                  return const Center(child: Text('Error loading data'));
                } else if (priorListController.items.value.isEmpty) {
                  return const Center(child: Text('No items found'));
                } else {
                  List<ItemModel> items = priorListController.items.value;
                    if (items.isEmpty) {
                      return const Center(
                        child: Text('No items match your search'),
                      );
                    }
                  return PriorListBuilder(items: items);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

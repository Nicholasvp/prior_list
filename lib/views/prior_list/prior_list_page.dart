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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final priorListController = autoInjector.get<PriorListController>();
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar...',
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
                onChanged: (val) => setState(() => _query = val),
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
                  if (_query.isNotEmpty) {
                    final q = _query.toLowerCase();
                    items = items.where((i) {
                      final title = i.title.toLowerCase();
                      final link = (i.linkUrl ?? '').toLowerCase();
                      return title.contains(q) || link.contains(q);
                    }).toList();
                    if (items.isEmpty) {
                      return const Center(
                        child: Text('No items match your search'),
                      );
                    }
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

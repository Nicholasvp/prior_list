import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/models/item_model.dart';
import 'package:prior_list/views/prior_list/edit_item_page.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PriorListBuilder extends StatelessWidget {
  final List<ItemModel> items;

  const PriorListBuilder({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final priorListController = autoInjector.get<PriorListController>();

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
              border: Border(
                left: BorderSide(color: Colors.blue[100]!, width: 6),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              onTap: () {
                priorListController.populateForEdit(item);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EditItemPage(item: item)),
                );
              },
              title: Text(
                item.title,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                item.priorDate != null
                    ? 'Due: ${DateFormat('dd/MM/yyyy').format(item.priorDate!)}'
                    : 'No due date',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.linkUrl != null && item.linkUrl!.isNotEmpty) ...[
                    IconButton(
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedLink01,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        launchUrlString(
                          item.linkUrl!,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      tooltip: 'Open Link',
                    ),
                    Gap(3),
                  ],
                  IconButton(
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedDelete01,
                      color: Colors.black,
                    ),
                    onPressed: () => priorListController.deleteItem(item.id),
                    tooltip: 'Excluir',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

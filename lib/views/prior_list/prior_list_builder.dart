import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:from_css_color/from_css_color.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/enums/enums.dart';
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
                left: BorderSide(
                  color: fromCssColor(item.color ?? '#fff'),
                  width: 6,
                ),
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
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Row(
                children: [
                  Text(
                    item.priorDate != null
                        ? 'item.due_date'.tr(
                            namedArgs: {
                              'date': DateFormat(
                                'dd/MM/yyyy',
                              ).format(item.priorDate!),
                            },
                          )
                        : 'item.no_due_date'.tr(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Gap(10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: switch (item.priorType) {
                        PriorType.high => Colors.red[200],
                        PriorType.medium => Colors.orange[200],
                        PriorType.low => Colors.green[200],
                      },
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      item.priorType.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
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
                    onPressed: () =>
                        priorListController.deleteItem(item.id, context),
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

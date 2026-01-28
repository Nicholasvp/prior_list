import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';

class ColorPickerWidget extends StatelessWidget {
  const ColorPickerWidget({super.key, required this.controller});
  final PriorListController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color'),
                  Gap(5),
                  SizedBox(
                    height: 50,
                    child: ValueListenableBuilder(
                      valueListenable: controller.selectedColor,
                      builder: (context, selectedColor, child) {
                        return ListView(
                          scrollDirection: Axis.horizontal,
                          children: Colors.primaries.map((color) {
                            final cssColor = '#${color.value.toRadixString(16).substring(2)}';
                            final isSelected = selectedColor == cssColor;
                            return GestureDetector(
                              onTap: () {
                                controller.selectedColor.value = cssColor;
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}
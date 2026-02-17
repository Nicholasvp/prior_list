import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

class TeamsMenu extends StatelessWidget {
  const TeamsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedUserGroup, color: Colors.black),
              Gap(5),
              Text('teams'.tr())
            ],
          )
        ],
      ),
    );
  }
}
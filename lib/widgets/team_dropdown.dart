import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:prior_list/models/team_model.dart';

class TeamDropdown extends StatelessWidget {
  final TextEditingController controller;
  final List<TeamModel> teams;
  final String hint;
  final VoidCallback onCreateTeam;

  const TeamDropdown({
    super.key,
    required this.controller,
    required this.teams,
    required this.onCreateTeam,
    this.hint = "Selecione um time",
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: controller.text.isNotEmpty ? controller.text : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'form.team.validation'.tr();
        }
        return null;
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ).copyWith(labelText: hint),
      items: [
        ...teams.map((team) {
          return DropdownMenuItem<String>(
            value: team.id,
            child: Text(team.name),
          );
        }),

        /// Botão no final
        const DropdownMenuItem<String>(
          value: "create_team",
          child: Row(
            children: [
              Icon(Icons.add),
              SizedBox(width: 8),
              Text("Criar novo time"),
            ],
          ),
        ),
      ],
      onChanged: (String? value) {
        if (value == "create_team") {
          onCreateTeam();
          return;
        }

        if (value != null) {
          controller.text = value;
        }
      },
    );
  }
}
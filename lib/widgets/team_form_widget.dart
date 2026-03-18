import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:prior_list/models/team_model.dart';
import 'package:random_string/random_string.dart';

class TeamFormWidget extends StatefulWidget {
  final TeamModel? team;
  final Function(TeamModel) onSubmit;

  const TeamFormWidget({super.key, this.team, required this.onSubmit});

  @override
  State<TeamFormWidget> createState() => _TeamFormWidgetState();
}

class _TeamFormWidgetState extends State<TeamFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.team != null) {
      _nameController.text = widget.team!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final team = TeamModel(
      id: widget.team?.id ?? randomAlpha(6).toUpperCase(),
      name: _nameController.text.trim(),
      ownerId: widget.team?.ownerId ?? '',
      createdAt: widget.team?.createdAt ?? DateTime.now(),
      members: widget.team?.members ?? [],
    );

    widget.onSubmit(team);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.team != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEditing
                  ? 'teams_page.edit_team'.tr()
                  : 'teams_page.create_team'.tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'teams_page.team_name'.tr(),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'teams_page.team_name_validation'.tr();
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(
                  isEditing
                      ? 'teams_page.edit_team'.tr()
                      : 'teams_page.create_team'.tr(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

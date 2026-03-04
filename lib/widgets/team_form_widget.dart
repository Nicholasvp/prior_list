import 'package:flutter/material.dart';
import 'package:prior_list/models/team_model.dart';

class TeamFormWidget extends StatefulWidget {
  final TeamModel? team;
  final Function(TeamModel) onSubmit;

  const TeamFormWidget({
    super.key,
    this.team,
    required this.onSubmit,
  });

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
      id: widget.team?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
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
              isEditing ? 'Edit Team' : 'Create Team',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Team name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a name';
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
                child: Text(isEditing ? 'Update' : 'Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
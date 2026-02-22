import 'package:flutter/material.dart';
import 'package:prior_list/controllers/team_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/models/team_model.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final TeamController controller = autoInjector.get<TeamController>();

  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.listenTeams();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teams')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// CREATE TEAM
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Team name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    controller.createTeam(
                      TeamModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _nameController.text.trim(),
                        ownerId: '', // será sobrescrito no controller
                        createdAt: DateTime.now(),
                        members: [],
                      ),
                    );
                  },
                  child: const Text('Create'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// LIST
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: controller.teams,
                builder: (_, teams, __) {
                  if (teams.isEmpty) {
                    return const Center(child: Text('No teams yet'));
                  }

                  return ListView.builder(
                    itemCount: teams.length,
                    itemBuilder: (_, index) {
                      final team = teams[index];

                      return Card(
                        child: ListTile(
                          title: Text(team.name),
                          subtitle: Text(team.id),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => controller.deleteTeam(team.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

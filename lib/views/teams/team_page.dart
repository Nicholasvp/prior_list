import 'package:flutter/material.dart';
import 'package:prior_list/controllers/team_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/models/team_model.dart';
import 'package:prior_list/widgets/team_card.dart';
import 'package:prior_list/widgets/team_form_widget.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final TeamController controller = autoInjector.get<TeamController>();

  @override
  void initState() {
    super.initState();

    /// 🔥 FETCH inicial
    // controller.fetchTeams();

    /// Se quiser usar stream ao invés de fetch:
    controller.listenTeams();
  }

  void _openForm({TeamModel? team}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TeamFormWidget(
        team: team,
        onSubmit: (teamModel) async {
          if (team == null) {
            await controller.createTeam(teamModel);
          } else {
            await controller.updateTeam(teamModel);
          }
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teams')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// ================= ERROR =================
                ValueListenableBuilder<String?>(
                  valueListenable: controller.errorMessage,
                  builder: (_, error, __) {
                    if (error == null) return const SizedBox();

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  },
                ),

                /// ================= LIST =================
                Expanded(
                  child: ValueListenableBuilder<List<TeamModel>>(
                    valueListenable: controller.teams,
                    builder: (_, teams, __) {
                      if (teams.isEmpty) {
                        return const Center(
                          child: Text(
                            'No teams yet',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: teams.length,
                        itemBuilder: (_, index) {
                          final team = teams[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TeamCard(
                              team: team,
                              onEdit: () => _openForm(team: team),
                              onDelete: () =>
                                  controller.deleteTeam(team.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                /// ================= CREATE BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Create New Team',
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () => _openForm(),
                  ),
                ),
              ],
            ),
          ),

          /// ================= LOADING OVERLAY =================
          ValueListenableBuilder<bool>(
            valueListenable: controller.isLoading,
            builder: (_, isLoading, __) {
              if (!isLoading) return const SizedBox();

              return Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
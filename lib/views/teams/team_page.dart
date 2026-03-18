import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:prior_list/controllers/team_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/models/team_model.dart';
import 'package:prior_list/repositories/auth_repository.dart';
import 'package:prior_list/widgets/team_card.dart';
import 'package:prior_list/widgets/team_form_widget.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final TeamController controller = autoInjector.get<TeamController>();
  final _authRepository = autoInjector.get<AuthRepository>();

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

  void _openJoinTeamForm() {
    final TextEditingController teamIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("teams_page.join_team".tr()),
          content: TextField(
            controller: teamIdController,
            decoration: InputDecoration(
              labelText: "teams_page.team_code".tr(),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o diálogo
              },
              child: Text("teams_page.cancel".tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                final teamId = teamIdController.text.trim();
                if (teamId.isNotEmpty) {
                  try {
                    await controller.addMember(
                      teamId: teamId,
                    ); // Chama o método addMember
                    Navigator.pop(context); // Fecha o diálogo
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("success".tr())));
                  } catch (e) {
                    // Mostra erro caso não consiga entrar no time
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("error".tr() + ": $e")),
                    );
                  }
                }
              },
              child: Text("teams_page.join_team".tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('teams_page.title'.tr())),
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
                        return Center(
                          child: Text(
                            'no_teams_found'.tr(),
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
                                  team.ownerId ==
                                      _authRepository.currentUser?.uid
                                  ? controller.deleteTeam(team.id)
                                  : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                /// ================= CREATE BUTTON =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => _openForm(),
                      child: Text("teams_page.create_team".tr()),
                    ),
                    ElevatedButton(
                      onPressed:
                          _openJoinTeamForm, // Abre o formulário para inserir o ID do time
                      child: Text("teams_page.join_team".tr()),
                    ),
                  ],
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
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ],
      ),
    );
  }
}

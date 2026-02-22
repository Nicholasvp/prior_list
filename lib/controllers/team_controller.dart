import 'package:flutter/material.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/models/team_model.dart';
import 'package:prior_list/repositories/team_repository.dart';
import 'package:prior_list/repositories/auth_repository.dart';

class TeamController {
  final _repository = autoInjector.get<TeamRepository>();
  final _authRepository = autoInjector.get<AuthRepository>();

  /// ================= STATE =================
  final teams = ValueNotifier<List<TeamModel>>([]);
  final isLoading = ValueNotifier<bool>(false);
  final errorMessage = ValueNotifier<String?>(null);

  String get _userId => _authRepository.currentUser!.uid;

  /// ================= CREATE =================
  Future<void> createTeam(TeamModel team) async {
    _setLoading(true);
    _clearError();

    try {
      final teamWithOwner = team.copyWith(ownerId: _userId);
      await _repository.createTeam(teamWithOwner);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// ================= FETCH =================
  Future<void> fetchTeams() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.getTeams(_userId);
      teams.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// ================= STREAM =================
  void listenTeams() {
    _repository.streamTeams(_userId).listen((data) {
      teams.value = data;
    });
  }

  /// ================= UPDATE =================
  Future<void> updateTeam(TeamModel team) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.updateTeam(team);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// ================= DELETE =================
  Future<void> deleteTeam(String teamId) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteTeam(teamId);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// ================= HELPERS =================
  void _setLoading(bool value) => isLoading.value = value;
  void _clearError() => errorMessage.value = null;

  void dispose() {
    teams.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
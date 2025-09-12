import 'package:flutter/cupertino.dart';

class StateController {
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> get isLoadingNotifier => _isLoading;
  set isLoading(bool value) => _isLoading.value = value;

  final ValueNotifier<bool> _hasError = ValueNotifier<bool>(false);
  ValueNotifier<bool> get hasErrorNotifier => _hasError;
  set hasError(bool value) => _hasError.value = value;

  final ValueNotifier<bool> _isEmpty = ValueNotifier<bool>(false);
  ValueNotifier<bool> get isEmptyNotifier => _isEmpty;
  set isEmpty(bool value) => _isEmpty.value = value;

  final ValueNotifier<bool> _isCompleted = ValueNotifier<bool>(false);
  ValueNotifier<bool> get isCompletedNotifier => _isCompleted;
  set isCompleted(bool value) => _isCompleted.value = value;

  final ValueNotifier<bool> _isInitial = ValueNotifier<bool>(true);
  ValueNotifier<bool> get isInitialNotifier => _isInitial;
  set isInitial(bool value) => _isInitial.value = value;

  final ValueNotifier<StateEnum> _state = ValueNotifier<StateEnum>(StateEnum.initial);
  ValueNotifier<StateEnum> get state => _state;
  set state(StateEnum value) => _state.value = value;

  void setState(StateEnum newState) {
    state = newState;
    isLoading = newState == StateEnum.loading;
    hasError = newState == StateEnum.error;
    isEmpty = newState == StateEnum.empty;
    isCompleted = newState == StateEnum.completed;
    isInitial = newState == StateEnum.initial;
  }

  void resetState() {
    setState(StateEnum.initial);
  }

  void loading() {
    setState(StateEnum.loading);
  }

  void error() {
    setState(StateEnum.error);
  }

  void empty() {
    setState(StateEnum.empty);
  }

  void completed() {
    setState(StateEnum.completed);
  }
}

enum StateEnum { initial, loading, error, empty, completed }

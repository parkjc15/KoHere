import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
class WindowState {
  final String id;
  final String title;
  final Offset position;
  final String? arg;

  WindowState({
    required this.id,
    required this.title,
    this.position = const Offset(20, 100),
    this.arg,
  });

  WindowState copyWith({
    Offset? position,
  }) {
    return WindowState(
      id: id,
      title: title,
      position: position ?? this.position,
      arg: arg ?? arg,
    );
  }
}

class WindowManagerNotifier extends StateNotifier<List<WindowState>> {
  WindowManagerNotifier() : super([]);

  void openWindow(WindowState newWindow) {
    if (state.any((w) => w.id == newWindow.id)) {
      bringToFront(newWindow.id);
      return;
    }
    state = [...state, newWindow];
  }

  void closeWindow(String id) {
    state = state.where((w) => w.id != id).toList();
  }

  void bringToFront(String id) {
    final windowIndex = state.indexWhere((w) => w.id == id);
    if (windowIndex != -1) {
      final window = state[windowIndex];
      final newState = List<WindowState>.from(state)..removeAt(windowIndex);
      newState.add(window);
      state = newState;
    }
  }

  void updatePosition(String id, Offset delta) {
    final windowIndex = state.indexWhere((w) => w.id == id);
    if (windowIndex != -1) {
      final window = state[windowIndex];
      // Note: In real app, we should constrain this based on screen size as well
      final newPosition = window.position + delta;
      
      final newState = List<WindowState>.from(state);
      newState[windowIndex] = window.copyWith(position: newPosition);
      state = newState;
    }
  }
}

final windowManagerProvider = StateNotifierProvider<WindowManagerNotifier, List<WindowState>>((ref) {
  return WindowManagerNotifier();
});

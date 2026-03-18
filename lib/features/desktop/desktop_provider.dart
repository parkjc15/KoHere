import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../auth/auth_service.dart';

class DesktopIconState {
  final String id;
  final Offset position;
  final bool isMoved;

  DesktopIconState({
    required this.id,
    required this.position,
    this.isMoved = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'dx': position.dx,
    'dy': position.dy,
    'isMoved': isMoved,
  };

  factory DesktopIconState.fromJson(Map<String, dynamic> json) => DesktopIconState(
    id: json['id'],
    position: Offset(json['dx'] ?? 0.0, json['dy'] ?? 0.0),
    isMoved: json['isMoved'] ?? false,
  );
}

class DesktopIconsNotifier extends StateNotifier<Map<String, DesktopIconState>> {
  final String? userId;

  DesktopIconsNotifier({this.userId}) : super({}) {
    _load();
  }

  static const String _prefKey = 'desktop_icon_positions';

  String _getKey() => userId != null ? '${userId}_$_prefKey' : _prefKey;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_getKey());
      if (data != null) {
        final Map<String, dynamic> decoded = jsonDecode(data);
        final newState = decoded.map((key, value) => MapEntry(
          key, 
          DesktopIconState.fromJson(value as Map<String, dynamic>)
        ));
        state = newState;
      }
    } catch (e) {
      debugPrint("Error loading desktop icons: $e");
    }
  }

  Future<void> updatePosition(String id, Offset position) async {
    final newState = {...state};
    newState[id] = DesktopIconState(id: id, position: position, isMoved: true);
    state = newState;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_getKey(), jsonEncode(state.map((k, v) => MapEntry(k, v.toJson()))));
  }
  
  void reset() {
    state = {};
  }
}

final desktopIconsProvider = StateNotifierProvider<DesktopIconsNotifier, Map<String, DesktopIconState>>((ref) {
  final user = ref.watch(authStateProvider).value;
  return DesktopIconsNotifier(userId: user?.uid);
});

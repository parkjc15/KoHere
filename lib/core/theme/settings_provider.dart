import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/auth_service.dart';

enum ExecutionMode { singleClick, doubleClick }
enum ScanlineMode { defaultMode, modern, vintage }

class SettingsNotifier extends StateNotifier<SettingsState> {
  final String? userId;
  
  SettingsNotifier({this.userId}) : super(SettingsState.initial()) {
    _loadSettings();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  static const String _keyExecutionMode = 'execution_mode';
  static const String _keyScanlineMode = 'scanline_mode';
  static const String _keyWeatherLevel = 'weather_level';

  String _getKey(String base) => userId != null ? '${userId}_$base' : base;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (_disposed) return;
    
    final modeIndex = prefs.getInt(_getKey(_keyExecutionMode)) ?? ExecutionMode.doubleClick.index;
    final scanlineIndex = prefs.getInt(_getKey(_keyScanlineMode)) ?? ScanlineMode.vintage.index;
    final weatherLevel = prefs.getInt(_getKey(_keyWeatherLevel)) ?? 0;
    
    state = state.copyWith(
      executionMode: ExecutionMode.values[modeIndex],
      scanlineMode: ScanlineMode.values[scanlineIndex],
      weatherLevel: weatherLevel,
    );
  }

  Future<void> setExecutionMode(ExecutionMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getKey(_keyExecutionMode), mode.index);
    if (_disposed) return;
    state = state.copyWith(executionMode: mode);
  }

  Future<void> setScanlineMode(ScanlineMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getKey(_keyScanlineMode), mode.index);
    if (_disposed) return;
    state = state.copyWith(scanlineMode: mode);
  }

  Future<void> setWeatherLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getKey(_keyWeatherLevel), level);
    if (_disposed) return;
    state = state.copyWith(weatherLevel: level);
  }
}

class SettingsState {
  final ExecutionMode executionMode;
  final ScanlineMode scanlineMode;
  final int weatherLevel; // 0 (Sunny) ~ 4 (Snowy)

  SettingsState({
    required this.executionMode,
    required this.scanlineMode,
    this.weatherLevel = 0,
  });

  factory SettingsState.initial() => SettingsState(
    executionMode: ExecutionMode.doubleClick,
    scanlineMode: ScanlineMode.vintage,
    weatherLevel: 0,
  );

  SettingsState copyWith({
    ExecutionMode? executionMode,
    ScanlineMode? scanlineMode,
    int? weatherLevel,
  }) {
    return SettingsState(
      executionMode: executionMode ?? this.executionMode,
      scanlineMode: scanlineMode ?? this.scanlineMode,
      weatherLevel: weatherLevel ?? this.weatherLevel,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final user = ref.watch(authStateProvider).value;
  return SettingsNotifier(userId: user?.uid);
});

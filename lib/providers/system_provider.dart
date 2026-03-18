import 'package:flutter_riverpod/legacy.dart';

class SystemState {
  final String weather;
  final String mood;
  final double brightness;
  final String? wallpaperPath;

  SystemState({
    this.weather = '맑음',
    this.mood = '평온함',
    this.brightness = 1.0,
    this.wallpaperPath,
  });

  SystemState copyWith({
    String? weather,
    String? mood,
    double? brightness,
    String? wallpaperPath,
  }) {
    return SystemState(
      weather: weather ?? this.weather,
      mood: mood ?? this.mood,
      brightness: brightness ?? this.brightness,
      wallpaperPath: wallpaperPath ?? this.wallpaperPath,
    );
  }
}

class SystemStateNotifier extends StateNotifier<SystemState> {
  SystemStateNotifier() : super(SystemState());

  void setWeather(String weather) => state = state.copyWith(weather: weather);
  void setMood(String mood) => state = state.copyWith(mood: mood);
  void setBrightness(double brightness) => state = state.copyWith(brightness: brightness);
  void setWallpaper(String? path) => state = state.copyWith(wallpaperPath: path);
}

final systemStateProvider = StateNotifierProvider<SystemStateNotifier, SystemState>((ref) {
  return SystemStateNotifier();
});

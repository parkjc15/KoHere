import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/kds.dart';
import 'core/theme/settings_provider.dart';
import 'features/boot/boot_screen.dart';

/// KoHere Application Entry Point
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: KohereApp()));
}

/// KoHere 메인 위젯
/// 
/// 디자인 시스템(KDS) 테마를 적용하고 앱의 첫 화면(BootScreen)을 설정합니다.
class KohereApp extends ConsumerWidget {
  const KohereApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherLevel = ref.watch(settingsProvider).weatherLevel;
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kohere',
      // KDS 1.0 디자인 시스템 테마 적용 (날씨 레벨에 따른 동적 테마)
      theme: KDS.getTheme(weatherLevel),
      // 전역 CRT 스캔라인 효과 적용
      builder: (context, child) => KdsScanlineOverlay(child: child!),
      // 부트(스플래시) 화면으로 시작
      home: const BootScreen(),
    );
  }
}

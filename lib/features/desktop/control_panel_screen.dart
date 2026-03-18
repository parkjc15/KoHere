import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/kds.dart';
import '../../core/theme/settings_provider.dart';

/// Mobile/9-ControlPanel Screen
/// 
/// 시스템 설정 및 환경 구성을 담당하는 제어판 화면입니다.
/// 날씨 시뮬레이션, 사용자 기분 선택, 바탕화면 프리셋 등의 
/// 커스터마이징 기능을 윈도우 스타일의 카드로 제공합니다.
class ControlPanelScreen extends ConsumerWidget {
  const ControlPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScanline = ref.watch(settingsProvider).scanlineMode;
    return Scaffold(
      backgroundColor: KDS.latteBeige,
      body: SafeArea(child: Column(children: [
        // 상단 헤더
        KdsHeader(title: "제어판"),
        
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            
            // ── Window 1: 날씨 시뮬레이션 (테마 및 환경 조절) ──
            KdsWindow(title: "날씨 시뮬레이션", child: Column(children: [
              // 현재 선택된 날씨 이모지 크게 표시
              Text(
                _getWeatherEmoji(ref.watch(settingsProvider).weatherLevel),
                style: TextStyle(fontSize: 48),
              ),
              SizedBox(height: 8),
              
              // 슬라이더 (5단계: 0~4)
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: KDS.espressoBlack,
                  inactiveTrackColor: KDS.espressoBlack.withValues(alpha: 0.2),
                  thumbColor: KDS.cream,
                  overlayColor: KDS.espressoBlack.withValues(alpha: 0.1),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8, elevation: 0),
                ),
                child: Slider(
                  value: ref.watch(settingsProvider).weatherLevel.toDouble(),
                  min: 0,
                  max: 4,
                  divisions: 4,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).setWeatherLevel(val.round());
                  },
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("☀️", style: TextStyle(fontSize: 20)),
                  Text("⛅", style: TextStyle(fontSize: 20)),
                  Text("☁️", style: TextStyle(fontSize: 20)),
                  Text("🌧️", style: TextStyle(fontSize: 20)),
                  Text("❄️", style: TextStyle(fontSize: 20)),
                ]),
              ),
              SizedBox(height: 16),
              
              // 주간 날씨 예보 타일 리스트 (현재 레벨에 따라 하이라이트 변경)
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _weatherTile("MON", "☀️", ref.watch(settingsProvider).weatherLevel == 0),
                SizedBox(width: 12),
                _weatherTile("TUE", "⛅", ref.watch(settingsProvider).weatherLevel == 1),
                SizedBox(width: 12),
                _weatherTile("WED", "☁️", ref.watch(settingsProvider).weatherLevel == 2),
                SizedBox(width: 12),
                _weatherTile("THU", "🌧️", ref.watch(settingsProvider).weatherLevel == 3),
              ]),
            ])),
            SizedBox(height: 12),
            
            // ── Window 2: 현재 기분 선택 (이모지 기반) ──
            KdsWindow(title: "현재 기분", child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _moodTile("😊", "기쁨", false),
                _moodTile("😌", "평온", true), // 활성화된 상태
                _moodTile("🔥", "활력", false),
                _moodTile("😴", "피곤", false),
                _moodTile("😢", "우울", false),
              ],
            )),
            SizedBox(height: 12),
            
            // ── Window 3: 바탕화면 설정 (CRT 스캔라인 프리셋) ──
            KdsWindow(title: "바탕화면 설정", child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text("기본 CRT 스캔라인 효과를 고르거나, 커스터마이징으로 직접 조정할 수 있어요.",
                style: TextStyle(fontSize: KDS.fontXs, color: KDS.gray)),
              SizedBox(height: 10),
              
              // 프리셋 선택 타일
              Row(children: [
                _presetTile(ref, "기본", ScanlineMode.defaultMode, currentScanline == ScanlineMode.defaultMode),
                SizedBox(width: 8),
                _presetTile(ref, "모던", ScanlineMode.modern, currentScanline == ScanlineMode.modern),
                SizedBox(width: 8),
                _presetTile(ref, "빈티지", ScanlineMode.vintage, currentScanline == ScanlineMode.vintage),
              ]),
              SizedBox(height: 10),
              
              // 커스터마이징 상세 페이지 이동 버튼
              KdsButton(label: "커스터마이징 열기", style: KdsButtonStyle.active, onTap: () {}),
              SizedBox(height: 8),
              Text("선택 시 현재 디자인된 바탕화면 커스터마이징 화면으로 이동", style: TextStyle(fontSize: 10, color: KDS.mochaBrown)),
            ])),
          ]),
        )),
      ])),
    );
  }

  static String _getWeatherEmoji(int level) {
    switch (level) {
      case 0: return "☀️";
      case 1: return "⛅";
      case 2: return "☁️";
      case 3: return "🌧️";
      case 4: return "❄️";
      default: return "☀️";
    }
  }

  /// 날씨 타일 생성용 빌더
  static Widget _weatherTile(String day, String emoji, bool active) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: active ? BoxDecoration(color: KDS.creamDark, borderRadius: BorderRadius.circular(4)) : null,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(day, style: TextStyle(fontSize: 10, color: KDS.gray)),
        SizedBox(height: 4),
        Text(emoji, style: TextStyle(fontSize: 20)),
      ]),
    );
  }

  /// 기분 선택 타일 생성용 빌더
  static Widget _moodTile(String emoji, String label, bool active) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: active ? BoxDecoration(color: KDS.creamDark, borderRadius: BorderRadius.circular(4)) : null,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: TextStyle(fontSize: 22)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: KDS.espressoBlack)),
      ]),
    );
  }

  /// 바탕화면 프리셋 타일 생성용 빌더
  static Widget _presetTile(WidgetRef ref, String label, ScanlineMode mode, bool active) {
    return Expanded(child: GestureDetector(
      onTap: () => ref.read(settingsProvider.notifier).setScanlineMode(mode),
      child: Container(
        height: 84,
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? KDS.mochaBrown : KDS.creamDark,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: KDS.espressoBlack, width: 2),
        ),
        child: Stack(
          children: [
            // 미니 스캔라인 프리뷰 효과
            Positioned.fill(
              child: Opacity(
                opacity: 0.6,
                child: CustomPaint(
                  painter: _MiniScanlinePainter(mode: mode, color: active ? KDS.cream : KDS.espressoBlack),
                ),
              ),
            ),
            Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.monitor, size: 28, color: active ? KDS.cream : KDS.espressoBlack),
                SizedBox(height: 6),
                Text(label, style: TextStyle(fontSize: KDS.fontXs, color: active ? KDS.cream : KDS.espressoBlack)),
              ]),
            ),
          ],
        ),
      ),
    ));
  }
}

/// 프리셋 버튼 내부에서 효과를 보여주기 위한 간이 페인터
class _MiniScanlinePainter extends CustomPainter {
  final ScanlineMode mode;
  final Color color;
  _MiniScanlinePainter({required this.mode, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double gap = 3.0;
    double opacity = 0.1;

    switch (mode) {
      case ScanlineMode.defaultMode: gap = 4.0; opacity = 0.20; break;
      case ScanlineMode.modern:      gap = 6.0; opacity = 0.15; break;
      case ScanlineMode.vintage:     gap = 2.0; opacity = 0.40; break;
    }

    final p = Paint()..color = color.withValues(alpha: opacity); 
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

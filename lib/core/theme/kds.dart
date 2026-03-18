import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_provider.dart';

/// KDS 1.0 — Kohere Design System
/// 
/// 이 클래스는 KoHere 앱의 시각적 언어를 정의하는 중앙 저장소입니다.
/// 모든 디자인 토큰(색상, 간격, 폰트)과 재사용 가능한 UI 컴포넌트를 포함합니다.
/// .pen 디자인 파일의 규격을 1:1로 준수합니다.
class KDS {
  KDS._();

  // ── Constant Spacing Tokens ──
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;
  static const double spacingXl = 24;

  // ── Constant Border & Font Tokens ──
  static const double borderWidth = 2;
  static const double radiusWindow = 6;
  static const double fontXs = 13;
  static const double fontSm = 15;
  static const double fontMd = 18;
  static const double fontLg = 22;
  static const double fontXl = 30;
  static const double fontXxl = 38;

  static const String fontFamily = 'NeoDunggeunmo';
  static const String englishFontFamily = 'Pixelify Sans';

  // ── Weather-Dependent Color Tokens ──
  static Color espressoBlack = const Color(0xFF1A1A1A);
  static Color mochaBrown    = const Color(0xFF5D4037);
  static Color highlight     = const Color(0xFF8B6F47);
  static Color white         = const Color(0xFFFFFFFF);
  static Color gray          = const Color(0xFF888888);
  static Color grayDark      = const Color(0xFF555555);

  // Dynamic Background and Surface Colors
  static Color latteBeige    = const Color(0xFFD2C5B1);
  static Color cream         = const Color(0xFFF5F5F0);
  static Color creamDark     = const Color(0xFFE8E4DB);
  static Color scanline      = const Color(0x151A1A1A);

  /// Updates global color tokens based on weather level (0 to 4)
  static void updateTheme(int level) {
    switch (level) {
      case 0: // Sunny (Default Warm)
        latteBeige = const Color(0xFFD2C5B1);
        cream = const Color(0xFFF5F5F0);
        creamDark = const Color(0xFFE8E4DB);
        mochaBrown = const Color(0xFF5D4037);
        break;
      case 1: // Partly Cloudy (Softer)
        latteBeige = const Color(0xFFC8BCAF);
        cream = const Color(0xFFF0EFEA);
        creamDark = const Color(0xFFE0DBD2);
        mochaBrown = const Color(0xFF554A46);
        break;
      case 2: // Overcast (Neutral Grayish)
        latteBeige = const Color(0xFFB8B3AC);
        cream = const Color(0xFFE8E8E4);
        creamDark = const Color(0xFFD4D4CE);
        mochaBrown = const Color(0xFF4A4A4A);
        break;
      case 3: // Rainy (Cooler Blue-Gray)
        latteBeige = const Color(0xFF9EA3A8);
        cream = const Color(0xFFDDE1E4);
        creamDark = const Color(0xFFC7CBD1);
        mochaBrown = const Color(0xFF37474F);
        break;
      case 4: // Snowy/Dark (Deep Calm/Contrast)
        latteBeige = const Color(0xFF8A9299);
        cream = const Color(0xFFCDD5DB);
        creamDark = const Color(0xFFB8C2C9);
        mochaBrown = const Color(0xFF263238);
        break;
    }
  }

  static ThemeData getTheme(int level) {
    updateTheme(level);
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: latteBeige,
      fontFamily: fontFamily,
      textTheme: GoogleFonts.pixelifySansTextTheme().apply(
        bodyColor: espressoBlack,
        displayColor: espressoBlack,
        fontFamilyFallback: [fontFamily],
      ),
      colorScheme: ColorScheme.light(
        primary: espressoBlack,
        secondary: mochaBrown,
        surface: cream,
        onPrimary: cream,
        onSecondary: cream,
        onSurface: espressoBlack,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: espressoBlack,
        centerTitle: true,
      ),
    );
  }
}

/// CRT 모니터 스캔라인 효과를 전체 화면에 입히는 오버레이 위젯
class KdsScanlineOverlay extends ConsumerWidget {
  final Widget child;
  const KdsScanlineOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(settingsProvider).scanlineMode;
    
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ScanlinePainter(mode: mode),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final ScanlineMode mode;
  _ScanlinePainter({required this.mode});

  @override
  void paint(Canvas canvas, Size size) {
    double gap = 3.0;
    double opacity = 0.04;

    switch (mode) {
      case ScanlineMode.defaultMode:
        gap = 4.0;
        opacity = 0.15;
        break;
      case ScanlineMode.modern:
        gap = 6.0;
        opacity = 0.10;
        break;
      case ScanlineMode.vintage:
        gap = 2.0;
        opacity = 0.30;
        break;
    }

    final p = Paint()..color = KDS.espressoBlack.withValues(alpha: opacity); 
    
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) => oldDelegate.mode != mode;
}

// ═══════════════════════════════════════
// Component/Window — Mac-style 윈도우 카드 위젯
// ═══════════════════════════════════════
/// .pen 디자인의 'Component/Window'를 구현합니다.
/// 상단에 스트라이프 패턴의 타이틀바가 있는 것이 특징입니다.
class KdsWindow extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onClose;
  const KdsWindow({super.key, required this.title, required this.child, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: KDS.cream,
        borderRadius: BorderRadius.circular(KDS.radiusWindow),
        border: Border.all(color: KDS.espressoBlack, width: KDS.borderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── TitleBar (스트라이프 그래디언트로 클래식 UI 재현) ──
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: List.generate(14, (i) => i.isEven ? KDS.latteBeige : KDS.creamDark),
                stops: List.generate(14, (i) => i / 14),
              ),
              border: Border(bottom: BorderSide(color: KDS.espressoBlack, width: KDS.borderWidth)),
            ),
            child: Row(
              children: [
                SizedBox(width: 4),
                // 왼쪽 작은 상자 장식물
                Container(
                  width: 14, height: 12,
                  decoration: BoxDecoration(
                    color: KDS.creamDark,
                    borderRadius: BorderRadius.circular(1),
                    border: Border.all(color: KDS.espressoBlack, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 6, height: 1.5, color: KDS.espressoBlack),
                      SizedBox(height: 1.5),
                      Container(width: 6, height: 1.5, color: KDS.espressoBlack),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(title, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: KDS.fontSm, color: KDS.espressoBlack)
                  )
                ),
                // ── 우측 X 닫기 버튼 ──
                if (onClose != null)
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: KDS.cream,
                        border: Border.all(color: KDS.espressoBlack, width: 1.5),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: Center(
                        child: Icon(Icons.close, size: 14, color: KDS.espressoBlack),
                      ),
                    ),
                  ),
                SizedBox(width: 2),
              ],
            ),
          ),
          // ── 콘텐츠 영역 ──
          Padding(
            padding: const EdgeInsets.all(KDS.spacingMd),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// Component/Button — 시스템 표준 3종 버튼
// ═══════════════════════════════════════
/// 크림(기본), 액티브(검정), 브라운(포인트) 3가지 스타일 지원
enum KdsButtonStyle { cream, active, brown }

class KdsButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final KdsButtonStyle style;
  const KdsButton({super.key, required this.label, this.onTap, this.style = KdsButtonStyle.cream});

  @override
  Widget build(BuildContext context) {
    final Color bg, fg;
    switch (style) {
      case KdsButtonStyle.active: bg = KDS.espressoBlack; fg = KDS.cream;
      case KdsButtonStyle.brown:  bg = KDS.mochaBrown;    fg = KDS.cream;
      case KdsButtonStyle.cream:  bg = KDS.cream;         fg = KDS.espressoBlack;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: KDS.espressoBlack, width: KDS.borderWidth),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontSize: KDS.fontSm, color: fg)),
      ),
    );
  }
}

// ═══════════════════════════════════════
// Component/Input — 텍스트 입력창 위젯
// ═══════════════════════════════════════
class KdsInput extends StatelessWidget {
  final String placeholder;
  final TextEditingController? controller;
  final bool obscure;
  final int maxLines;
  final double? height;
  const KdsInput({super.key, required this.placeholder, this.controller, this.obscure = false, this.maxLines = 1, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: KDS.white,
        border: Border.all(color: KDS.espressoBlack, width: KDS.borderWidth),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        maxLines: obscure ? 1 : maxLines,
        style: TextStyle(fontSize: KDS.fontSm, color: KDS.espressoBlack),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(fontSize: KDS.fontSm, color: KDS.mochaBrown),
          border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
// Component/Checkbox — 체크박스 위젯
// ═══════════════════════════════════════
class KdsCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  const KdsCheckbox({super.key, required this.label, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16, height: 16,
            decoration: BoxDecoration(
              color: KDS.cream,
              border: Border.all(color: KDS.espressoBlack, width: 2),
            ),
            child: value
              ? Center(child: Text("✓", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: KDS.espressoBlack)))
              : null,
          ),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: KDS.fontSm, color: KDS.espressoBlack)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// Component/Header — 화면별 상단 내비게이션 바
// ═══════════════════════════════════════
class KdsHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showBackButton;

  const KdsHeader({
    super.key, 
    required this.title, 
    this.onBack, 
    this.trailing,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          showBackButton 
            ? GestureDetector(
                onTap: onBack ?? () => Navigator.pop(context),
                child: Icon(Icons.arrow_back, color: KDS.espressoBlack, size: 20),
              )
            : SizedBox(width: 20),
          Text(title, style: TextStyle(fontSize: KDS.fontMd, fontWeight: FontWeight.bold, color: KDS.espressoBlack)),
          trailing ?? SizedBox(width: 20),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// Component/TabPill — 메인 하단 4탭 내비게이션
// ═══════════════════════════════════════
class KdsTabPill extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTap;
  const KdsTabPill({super.key, required this.selectedIndex, this.onTap});

  static const _tabs = [
    (icon: Icons.desktop_mac, label: '데스크탑'),
    (icon: Icons.edit_note, label: '로그'),
    (icon: Icons.map, label: '지도'),
    (icon: Icons.person, label: '나'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Container(
        height: 56,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: KDS.cream,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: KDS.espressoBlack, width: KDS.borderWidth),
        ),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final active = i == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap?.call(i),
                child: Container(
                  decoration: BoxDecoration(
                    color: active ? KDS.espressoBlack : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _tabs[i].icon, 
                        size: 22, 
                        color: active ? KDS.cream : KDS.mochaBrown
                      ),
                      SizedBox(height: 2),
                      Text(
                        _tabs[i].label, 
                        style: TextStyle(
                          fontSize: 11, 
                          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                          color: active ? KDS.cream : KDS.mochaBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
// Component/MenuBar — 데스크탑 상단 정적 메뉴바
// ═══════════════════════════════════════
class KdsMenuBar extends StatelessWidget {
  const KdsMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: KDS.white,
        border: Border(bottom: BorderSide(color: KDS.espressoBlack, width: KDS.borderWidth)),
      ),
      child: Row(
        children: [
          Icon(Icons.coffee, size: 18, color: KDS.espressoBlack),
          SizedBox(width: 16),
          Text("파일", style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold, color: KDS.espressoBlack)),
          SizedBox(width: 16),
          ...(["편집", "지역", "특별"].map((t) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(t, style: TextStyle(fontSize: KDS.fontSm, color: KDS.espressoBlack)),
          ))),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// Component/DesktopIcon — 바탕화면 앱 바로가기 아이콘
// ═══════════════════════════════════════
class KdsDesktopIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final bool isSelected;

  const KdsDesktopIcon({
    super.key, 
    required this.icon, 
    required this.label, 
    this.onTap, 
    this.onDoubleTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: isSelected ? KDS.espressoBlack : KDS.cream,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: KDS.espressoBlack, width: KDS.borderWidth),
              ),
              child: Icon(
                icon, 
                size: 28, 
                color: isSelected ? KDS.cream : KDS.mochaBrown,
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              decoration: isSelected ? BoxDecoration(
                color: KDS.espressoBlack,
                borderRadius: BorderRadius.circular(2),
              ) : null,
              child: Text(
                label, 
                textAlign: TextAlign.center, 
                style: TextStyle(
                  fontSize: KDS.fontXs, 
                  color: isSelected ? KDS.cream : KDS.espressoBlack,
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// ═══════════════════════════════════════
// Component/AppIcon — KoHere 시그니처 앱 아이콘 위젯
// ═══════════════════════════════════════
class KdsAppIcon extends StatelessWidget {
  final double size;
  final Animation<double>? steamAnimation; // 수증기 애니메이션 연동
  final bool hasBorder; // 외각 테두리 유무 (부팅 화면용)

  const KdsAppIcon({
    super.key, 
    this.size = 128,
    this.steamAnimation,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: steamAnimation ?? kAlwaysCompleteAnimation,
        builder: (context, _) {
          return CustomPaint(
            painter: _AppIconPainter(
              steamValue: steamAnimation?.value,
              hasBorder: hasBorder,
            ),
          );
        },
      ),
    );
  }
}

class _AppIconPainter extends CustomPainter {
  final double? steamValue;
  final bool hasBorder;

  _AppIconPainter({this.steamValue, this.hasBorder = false});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 128.0;
    
    // 1. 전체 배경
    final bgPaint = Paint()..color = KDS.cream;
    if (hasBorder) {
      // 부팅 화면용: 18px 라운드 사각형 배경 (96px 기준이므로 배율 적용)
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(24 * s), // .pen의 18px (96기준) -> 128기준으로 환산시 약 24
      );
      canvas.drawRRect(rrect, bgPaint);
      
      // 테두리 추가
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = KDS.espressoBlack
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 * s,
      );
    } else {
      // 앱 아이콘 자산 생성용: 꽉 찬 배경
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        bgPaint,
      );
    }

    // 2. 컵 그림자 (BeanShadow - Latte Beige)
    canvas.drawOval(
      Rect.fromLTWH(24 * s, 88 * s, 80 * s, 20 * s),
      Paint()..color = KDS.latteBeige
    );

    // 3. 커피 컵 (Cup - Mocha Brown Outline)
    final cupPaint = Paint()
      ..color = KDS.mochaBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * s
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    // 컵 본체 형상 (Mug Outline)
    final cupPath = Path()
      ..moveTo(46 * s, 36 * s) 
      ..lineTo(82 * s, 36 * s) 
      ..lineTo(80 * s, 64 * s) 
      ..quadraticBezierTo(64 * s, 74 * s, 48 * s, 64 * s) 
      ..close();
    
    // 컵 내부 액체 수평선
    canvas.drawLine(Offset(46 * s, 48 * s), Offset(82 * s, 48 * s), cupPaint);
    
    // 손잡이 (Handle)
    final handlePath = Path()
      ..moveTo(82 * s, 42 * s)
      ..quadraticBezierTo(94 * s, 42 * s, 94 * s, 54 * s)
      ..quadraticBezierTo(94 * s, 66 * s, 82 * s, 66 * s);

    // 4. 수증기 애니메이션 (Steam - 위로 피어오르는 효과)
    if (steamValue != null) {
      final steamPaint = Paint()
        ..color = KDS.mochaBrown.withAlpha((50 * (1 - steamValue!)).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * s
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < 3; i++) {
        final double steamX = (52 + i * 12) * s;
        final double steamY = (30 - (steamValue! * 20)) * s;
        final double wave = math.sin(steamValue! * 6 + i) * 3 * s;
        
        final path = Path()
          ..moveTo(steamX + wave, steamY)
          ..quadraticBezierTo(steamX - wave, steamY - 5 * s, steamX + wave, steamY - 10 * s);
        
        canvas.drawPath(path, steamPaint);
      }
    }

    canvas.drawPath(cupPath, cupPaint);
    canvas.drawPath(handlePath, cupPaint);
    
    // 받침대 직선 (Saucer line)
    canvas.drawLine(Offset(46 * s, 78 * s), Offset(82 * s, 78 * s), cupPaint);

    // 5. 반짝임 (Sparkle - Top Right)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(90 * s, 20 * s, 16 * s, 16 * s), Radius.circular(4 * s)),
      Paint()..color = KDS.espressoBlack
    );

    // 6. 픽셀 포인트 (Accents)
    canvas.drawRect(Rect.fromLTWH(16 * s, 16 * s, 8 * s, 8 * s), Paint()..color = KDS.espressoBlack);
    canvas.drawRect(Rect.fromLTWH(104 * s, 104 * s, 8 * s, 8 * s), Paint()..color = KDS.espressoBlack);
  }

  @override
  bool shouldRepaint(covariant _AppIconPainter oldDelegate) => oldDelegate.steamValue != steamValue;
}

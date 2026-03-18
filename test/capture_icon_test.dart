import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// App Icon Generation Script V4
/// 
/// 배경을 크림색(#F5F5F0)으로 꽉 채우고, 외곽의 검정 테두리를 제거한 
/// 고해상도(1024x1024) 앱 아이콘을 생성합니다.
void main() {
  testWidgets('Generate Solid Cream App Icon', (tester) async {
    const double size = 1024.0;
    const double s = size / 128.0; 
    
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, size, size));
    
    // -- Colors --
    const espressoBlack = Color(0xFF1A1A1A);
    const latteBeige = Color(0xFFD2C5B1);
    const mochaBrown = Color(0xFF5D4037);
    const cream = Color(0xFFF5F5F0);

    // 1. 전체 배경 (크림색으로 꽉 채움)
    canvas.drawRect(const Rect.fromLTWH(0, 0, size, size), Paint()..color = cream);

    // 2. 컵 그림자 (BeanShadow)
    final shadowPaint = Paint()..color = latteBeige..isAntiAlias = true;
    canvas.drawOval(
      Rect.fromLTWH(24 * s, 88 * s, 80 * s, 20 * s),
      shadowPaint,
    );

    // 3. 커피 컵 (Cup - Mocha Brown Outline)
    final cupPaint = Paint()
      ..color = mochaBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * s
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..isAntiAlias = true;

    // 컵 본체
    final cupPath = Path()
      ..moveTo(46 * s, 36 * s) 
      ..lineTo(82 * s, 36 * s) 
      ..lineTo(80 * s, 64 * s) 
      ..quadraticBezierTo(64 * s, 74 * s, 48 * s, 64 * s) 
      ..close();
    
    // 액체 수평선
    canvas.drawLine(Offset(46 * s, 48 * s), Offset(82 * s, 48 * s), cupPaint);
    
    // 손잡이
    final handlePath = Path()
      ..moveTo(82 * s, 42 * s)
      ..quadraticBezierTo(94 * s, 42 * s, 94 * s, 54 * s)
      ..quadraticBezierTo(94 * s, 66 * s, 82 * s, 66 * s);

    canvas.drawPath(cupPath, cupPaint);
    canvas.drawPath(handlePath, cupPaint);
    
    // 받침대 선
    canvas.drawLine(Offset(46 * s, 78 * s), Offset(82 * s, 78 * s), cupPaint);

    // 4. 반짝임 (Sparkle)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(90 * s, 20 * s, 16 * s, 16 * s), const Radius.circular(4 * s)),
      Paint()..color = espressoBlack
    );

    // 5. 픽셀 포인트 (Accents)
    canvas.drawRect(Rect.fromLTWH(16 * s, 16 * s, 8 * s, 8 * s), Paint()..color = espressoBlack);
    canvas.drawRect(Rect.fromLTWH(104 * s, 104 * s, 8 * s, 8 * s), Paint()..color = espressoBlack);

    // 이미지 저장
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    final file = File('assets/app_icon.png');
    await file.writeAsBytes(byteData!.buffer.asUint8List());
  });
}

import 'package:flutter/material.dart';
import '../../core/theme/kohere_theme.dart';

class PixelDitheredImage extends StatelessWidget {
  final String? imagePath;
  final double size;

  const PixelDitheredImage({
    super.key,
    this.imagePath,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: KohereTheme.espressoBlack, width: 2),
        ),
        child: Icon(Icons.camera_alt_outlined, color: KohereTheme.mochaBrown, size: 40),
      );
    }

    // 실제 이미지를 픽셀화하여 보여주는 시뮬레이션
    // (여기서는 실제 프로세싱 대신 아티스틱한 필터를 적용한 것처럼 스택으로 표현)
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: KohereTheme.espressoBlack, width: 2),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
            // Placeholder or Actual Image with Filter logic
            ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      1, 0,
                ]), // Grayscale
                child: Image.network(
                    "https://picsum.photos/seed/${imagePath.hashCode}/200", // 시뮬레이션을 위한 랜덤 이미지
                    fit: BoxFit.cover,
                ),
            ),
            // Dithering Pattern Overlay
            CustomPaint(
                painter: DitherPatternPainter(),
            ),
        ],
      ),
    );
  }
}

class DitherPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = KohereTheme.espressoBlack.withAlpha(100)
      ..strokeWidth = 1;

    // 픽셀 도트 패턴을 그려서 디더링 느낌을 줌
    for (double i = 0; i < size.width; i += 3) {
      for (double j = 0; j < size.height; j += 3) {
        if ((i + j) % 6 == 0) {
            canvas.drawRect(Rect.fromLTWH(i, j, 1.5, 1.5), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import '../../core/theme/kohere_theme.dart';

class MacWindow extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onClose;
  final double? width;
  final double? height;
  final Function(Offset)? onDrag;
  final VoidCallback? onTap;

  const MacWindow({
    super.key,
    required this.title,
    required this.child,
    required this.onClose,
    this.width,
    this.height,
    this.onDrag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? MediaQuery.of(context).size.width * 0.85,
        height: height ?? MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: KohereTheme.cream,
          border: Border.all(color: KohereTheme.espressoBlack, width: 3),
          boxShadow: [
            BoxShadow(
              color: KohereTheme.espressoBlack,
              offset: Offset(8, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Window Header (Title Bar)
            GestureDetector(
              onPanUpdate: (details) {
                if (onDrag != null) onDrag!(details.delta);
              },
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: KohereTheme.espressoBlack, width: 2),
                  ),
                ),
                child: Row(
                children: [
                  // Close Box
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: GestureDetector(
                      onTap: onClose,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: KohereTheme.espressoBlack, width: 2),
                        ),
                        child: Center(
                          child: Icon(Icons.close, size: 14, color: KohereTheme.espressoBlack),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Decorative Lines
                  Expanded(
                    flex: 1,
                    child: CustomPaint(
                      painter: HeaderLinesPainter(),
                      size: const Size.fromHeight(20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: CustomPaint(
                      painter: HeaderLinesPainter(),
                      size: const Size.fromHeight(20),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
            // Window Body
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = KohereTheme.espressoBlack
      ..strokeWidth = 1;

    for (double i = 6; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

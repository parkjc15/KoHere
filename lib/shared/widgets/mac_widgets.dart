import 'package:flutter/material.dart';
import 'package:kohere/core/theme/kohere_theme.dart';

class MacDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const MacDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: KohereTheme.cream,
          border: Border.all(color: KohereTheme.espressoBlack, width: 3),
          boxShadow: [
             BoxShadow(
              color: KohereTheme.espressoBlack,
              offset: Offset(6, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Bar
            Container(
              height: 30,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: KohereTheme.espressoBlack, width: 2),
                ),
              ),
              child: Stack(
                children: [
                   Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Close box (Classic Mac style)
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        border: Border.all(color: KohereTheme.espressoBlack, width: 2),
                      ),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Center(
                          child: Icon(Icons.close, size: 12, color: KohereTheme.espressoBlack),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: content,
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MacButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isDefault;

  const MacButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isDefault = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDefault ? KohereTheme.espressoBlack : KohereTheme.cream,
        border: Border.all(color: KohereTheme.espressoBlack, width: 3),
        boxShadow: isDefault ? null : [
          BoxShadow(
            color: KohereTheme.espressoBlack,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: isDefault ? KohereTheme.cream : KohereTheme.espressoBlack,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

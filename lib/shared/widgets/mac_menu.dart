import 'package:flutter/material.dart';
import '../../core/theme/kohere_theme.dart';

class MacMenuEntry {
  final String label;
  final VoidCallback onTap;

  MacMenuEntry({required this.label, required this.onTap});
}

class MacMenuBarItem extends StatefulWidget {
  final String label;
  final List<MacMenuEntry> entries;

  const MacMenuBarItem({
    super.key,
    required this.label,
    required this.entries,
  });

  @override
  State<MacMenuBarItem> createState() => _MacMenuBarItemState();
}

// 전역 상태: 현재 열려있는 메뉴를 닫는 콜백
void Function()? _activeMenuCloseCallback;

class _MacMenuBarItemState extends State<MacMenuBarItem> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    // 이미 열려있는 다른 메뉴가 있다면 강제 종료 (배타적 동작)
    _activeMenuCloseCallback?.call();
    _activeMenuCloseCallback = _closeMenu;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeMenu() {
    if (_activeMenuCloseCallback == _closeMenu) {
      _activeMenuCloseCallback = null;
    }
    
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    Offset globalPos = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 메뉴바 위쪽 영역 터치 시 닫기 및 이벤트 흡수
          if (globalPos.dy > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: globalPos.dy,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeMenu,
                child: SizedBox.expand(),
              ),
            ),
          // 메뉴바 아래쪽 영역 (바탕화면) 터치 시 닫기 및 이벤트 흡수
          Positioned(
            top: globalPos.dy + size.height,
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeMenu,
              child: SizedBox.expand(),
            ),
          ),
          Positioned(
            width: 150,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height),
              child: Material(
                elevation: 0,
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: KohereTheme.cream,
                    border: Border.all(color: KohereTheme.espressoBlack, width: 2),
                    boxShadow: [
                      BoxShadow(color: KohereTheme.espressoBlack, offset: Offset(4, 4)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.entries.map((entry) {
                      return InkWell(
                        onTap: () {
                          _closeMenu();
                          entry.onTap();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: KohereTheme.espressoBlack, width: 1)),
                          ),
                          child: Text(
                            entry.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: KohereTheme.espressoBlack,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleMenu,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: _isOpen ? KohereTheme.espressoBlack : Colors.transparent,
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: _isOpen ? KohereTheme.cream : KohereTheme.cream,
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

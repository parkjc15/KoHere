import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/kds.dart';
import '../log/coffee_log_screen.dart';
import '../log/log_list_screen.dart';
import 'map_screen.dart';
import 'me_screen.dart';
import 'control_panel_screen.dart';
import '../share/share_screen.dart';
import '../../core/theme/settings_provider.dart';
import 'desktop_provider.dart';
import 'settings_screen.dart';

/// Mobile/6-Desktop Screen
/// 
/// 앱의 메인 허브 화면입니다. 클래식 OS의 바탕화면을 모티브로 하며,
/// 상단 메뉴바와 바탕화면 아이콘들을 통해 주요 기능에 접근할 수 있습니다.
/// 하단 탭 바(KdsTabPill)를 통해 데스크탑/로그리스트/지도/사용자 화면 간 전환을 관리합니다.
class DesktopScreen extends ConsumerStatefulWidget {
  const DesktopScreen({super.key});
  @override ConsumerState<DesktopScreen> createState() => _DesktopScreenState();
}

class _DesktopScreenState extends ConsumerState<DesktopScreen> {
  // 현재 선택된 하단 탭 인덱스 (0: 데스크탑, 1: 로그, 2: 지도, 3: 나)
  int _tab = 0;

  // ── 데스크탑 아이콘 관리 ──
  late List<_DesktopIconData> _icons;
  bool _showCoffeeWindow = false;

  @override
  void initState() {
    super.initState();
    // 초기 아이콘 배치 구성
    _icons = [
      _DesktopIconData(id: 'coffee', icon: Icons.edit_note, label: ".coffee", onTap: () => setState(() => _showCoffeeWindow = true)),
      _DesktopIconData(id: 'folder1', icon: Icons.folder, label: "성수", screen: const LogListScreen()),
      _DesktopIconData(id: 'folder2', icon: Icons.folder, label: "합정", screen: const LogListScreen()),
      _DesktopIconData(id: 'folder3', icon: Icons.folder, label: "연남", screen: const LogListScreen()),
      _DesktopIconData(id: 'control', icon: Icons.tune, label: "제어판", screen: const ControlPanelScreen()),
      _DesktopIconData(id: 'share', icon: Icons.share, label: "공유", screen: const ShareScreen()),
      _DesktopIconData(id: 'dither', icon: Icons.image, label: "디더링"),
      _DesktopIconData(id: 'settings', icon: Icons.settings, label: "설정", screen: const SettingsScreen()),
    ];

    // 저장된 위치 정보 불러와서 초기화 (비동기 로딩을 기다리지 않고 현재 상태만 반영)
    _syncIconPositions();
  }

  void _syncIconPositions() {
    final iconStates = ref.read(desktopIconsProvider);
    for (var icon in _icons) {
      if (iconStates.containsKey(icon.id)) {
        icon.position = iconStates[icon.id]!.position;
        icon.isMoved = iconStates[icon.id]!.isMoved;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KDS.latteBeige,
      body: SafeArea(
        child: _buildTab(),
      ),
    );
  }

  Widget _buildTab() {
    switch (_tab) {
      case 1: return _wrapWithTab(LogListScreen(embedded: true, onBack: () => setState(() => _tab = 0)), 1);
      case 2: return _wrapWithTab(MapScreen(embedded: true, onBack: () => setState(() => _tab = 0)), 2);
      case 3: return _wrapWithTab(MeScreen(embedded: true, onBack: () => setState(() => _tab = 0)), 3);
      default: return _wrapWithTab(_buildDesktop(), 0);
    }
  }

  Widget _wrapWithTab(Widget body, int idx) {
    return Column(children: [
      Expanded(child: body),
      KdsTabPill(
        selectedIndex: idx, 
        onTap: (i) => setState(() => _tab = i)
      ),
    ]);
  }

  /// 데스크탑(바탕화면) 모드: 아이콘 드래그 앤 드롭 지원
  Widget _buildDesktop() {
    return Column(
      children: [
        // 상단 정적 메뉴바
        const KdsMenuBar(),
        
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext lbc, BoxConstraints constraints) {
              const double spacingX = 84.0;
              const double spacingY = 96.0;
              
              // 현재 화면에서 가능한 최대 열 개수와 중앙 정렬을 위한 시작점 계산
              int cols = (constraints.maxWidth / spacingX).floor();
              if (cols < 1) cols = 1;
              final int actualCols = math.min(cols, _icons.length);
              final double gridWidth = actualCols * spacingX;
              final double startX = (constraints.maxWidth - gridWidth) / 2;

              return Stack(
                children: [
                  // ── 배경 워터마크 텍스트 ──
                  Center(
                    child: Opacity(
                      opacity: 0.1,
                      child: Text(
                        "KoHere OS v1.0",
                        style: TextStyle(
                          fontFamily: KDS.fontFamily,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: KDS.mochaBrown,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  
                  // ── 배경 영역 (Drag를 받기 위한 투명 레이어) ──
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          for (var icon in _icons) {
                            icon.isSelected = false;
                          }
                        });
                      },
                      child: DragTarget<String>(
                        onAcceptWithDetails: (DragTargetDetails<String> details) {
                          final RenderBox? renderBox = lbc.findRenderObject() as RenderBox?;
                          if (renderBox == null) return;
                          final Offset localOffset = renderBox.globalToLocal(details.offset);
                          
                          setState(() {
                            final index = _icons.indexWhere((icon) => icon.id == details.data);
                            if (index != -1) {
                              // 그리드 시작점(startX)을 기준으로 상대적인 칸(Column/Row) 계산 후 스냅
                              double relX = localOffset.dx - startX;
                              double relY = localOffset.dy - 16.0;
                              
                              // 84x96 그리드 단위로 딱 맞게 스냅
                              double snappedRelX = (relX / spacingX).round() * spacingX;
                              double snappedRelY = (relY / spacingY).round() * spacingY;
                              
                              // ── 화면 밖이나 그리드 영역 밖으로 나가지 않도록 제한 (사이드 이탈 방지) ──
                              snappedRelX = snappedRelX.clamp(0.0, gridWidth - spacingX);
                              snappedRelY = snappedRelY.clamp(0.0, constraints.maxHeight - 16.0 - 90.0);
 
                              // ── 중복 위치 확인 (겹침 방지) ──
                              final Offset targetPos = Offset(snappedRelX, snappedRelY);
                              bool isOccupied = false;
                              
                              for (int i = 0; i < _icons.length; i++) {
                                if (_icons[i].id == details.data) continue;
                                
                                Offset otherPos;
                                if (_icons[i].isMoved) {
                                  otherPos = _icons[i].position;
                                } else {
                                  final int row = i ~/ cols;
                                  final int col = i % cols;
                                  otherPos = Offset(col * spacingX, row * spacingY);
                                }
                                
                                if (otherPos == targetPos) {
                                  isOccupied = true;
                                  break;
                                }
                              }
 
                              if (isOccupied) {
                                _showMsg("해당 위치에 이미 다른 아이콘이 있습니다.");
                              } else {
                                setState(() {
                                  _icons[index].position = targetPos;
                                  _icons[index].isMoved = true;
                                });
                                // 위치 정보 영구 저장
                                ref.read(desktopIconsProvider.notifier).updatePosition(details.data, targetPos);
                              }
                            }
                          });
                        },
                        builder: (context, candidateData, rejectedData) => Container(color: Colors.transparent),
                      ),
                    ),
                  ),
                  
                  // ── 드래그 가능한 아이콘들 ──
                  ..._icons.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final _DesktopIconData item = entry.value;

                    // 저장된 위치 정보와 현재 화면 위치 동기화
                    final iconStates = ref.watch(desktopIconsProvider);
                    if (iconStates.containsKey(item.id)) {
                      item.position = iconStates[item.id]!.position;
                      item.isMoved = iconStates[item.id]!.isMoved;
                    }

                    // 표시될 최종 위치 계산
                    Offset currentPos;
                    if (item.isMoved) {
                      // 수동 배치된 아이콘: 저장된 상대 좌표 + 현재의 그리드 시작점
                      currentPos = Offset(startX + item.position.dx, 16.0 + item.position.dy);
                    } else {
                      // 자동 배치 아이콘: 인덱스 기반으로 중앙 정렬 위치 계산
                      final int row = index ~/ cols;
                      final int col = index % cols;
                      currentPos = Offset(startX + col * spacingX, row * spacingY + 16.0);
                    }

                    return Positioned(
                      left: currentPos.dx,
                      top: currentPos.dy,
                      key: ValueKey(item.id),
                      child: Draggable<String>(
                        data: item.id,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Opacity(
                            opacity: 0.7,
                            child: KdsDesktopIcon(icon: item.icon, label: item.label, isSelected: item.isSelected),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: KdsDesktopIcon(icon: item.icon, label: item.label, isSelected: item.isSelected),
                        ),
                        child: KdsDesktopIcon(
                          icon: item.icon, 
                          label: item.label,
                          isSelected: item.isSelected,
                          onTap: () {
                            final mode = ref.read(settingsProvider).executionMode;
                            
                            if (mode == ExecutionMode.singleClick) {
                              // 원클릭 모드: 즉시 실행
                              if (item.onTap != null) {
                                item.onTap!();
                              } else if (item.screen != null) {
                                _push(item.screen!);
                              }
                            } else {
                              // 더블클릭 모드: 선택 처리
                              setState(() {
                                for (var icon in _icons) {
                                  icon.isSelected = false;
                                }
                                item.isSelected = true;
                              });
                            }
                          },
                          onDoubleTap: () {
                            final mode = ref.read(settingsProvider).executionMode;
                            if (mode == ExecutionMode.doubleClick) {
                              // 더블클릭 모드에서만 동작
                              if (item.onTap != null) {
                                item.onTap!();
                              } else if (item.screen != null) {
                                _push(item.screen!);
                              }
                            }
                          },
                        ),
                      ),
                    );
                  }),

                  // ── .coffee 윈도우 오버레이 ──
                  if (_showCoffeeWindow)
                    Positioned.fill(
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: InkWell(
                          onTap: () => setState(() => _showCoffeeWindow = false),
                          overlayColor: WidgetStateProperty.all(Colors.transparent),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              child: InkWell(
                                onTap: () {}, 
                                overlayColor: WidgetStateProperty.all(Colors.transparent),
                                child: KdsWindow(
                                  title: "new_log.coffee",
                                  onClose: () => setState(() => _showCoffeeWindow = false),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      // 타이틀바와 여백을 고려하여 가용 높이에서 120px을 제외한 나머지를 최대 높이로 설정
                                      maxHeight: (constraints.maxHeight - 120).clamp(200.0, double.infinity),
                                    ),
                                    child: CoffeeLogScreen(
                                      isWindow: true,
                                      onSave: () => setState(() => _showCoffeeWindow = false),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _push(Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// 바탕화면 아이콘 데이터 모델
class _DesktopIconData {
  final String id;
  final String label;
  final IconData icon;
  final Widget? screen;
  final VoidCallback? onTap;
  Offset position;
  bool isMoved; // 사용자가 수동으로 위치를 잡았는지 여부
  bool isSelected;

  _DesktopIconData({
    required this.id,
    required this.label,
    required this.icon,
    this.screen,
    this.onTap,
    this.position = Offset.zero,
    this.isMoved = false,
    this.isSelected = false,
  });
}

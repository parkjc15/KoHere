import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/kds.dart';
import '../../core/theme/settings_provider.dart';

/// App Settings Screen
/// 
/// 앱의 전역 환경 설정을 관리하는 화면입니다.
class SettingsScreen extends ConsumerStatefulWidget {
  final bool embedded;
  final VoidCallback? onBack;

  const SettingsScreen({super.key, this.embedded = false, this.onBack});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // 임시 로컬 설정 (실제로는 서버나 다른 프로바이더에 저장할 수 있음)
  bool _locRec = true;
  bool _autoTag = true;

  @override
  Widget build(BuildContext context) {
    return widget.embedded 
      ? _body() 
      : Scaffold(backgroundColor: KDS.latteBeige, body: SafeArea(child: _body()));
  }

  Widget _body() {
    return Column(
      children: [
        KdsHeader(
          title: "시스템 설정",
          onBack: widget.onBack ?? (widget.embedded ? null : () => Navigator.pop(context)),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KdsWindow(
                  title: "환경 설정", 
                  child: Column(children: [
                    KdsCheckbox(label: "위치 기반 로컬 추천", value: _locRec, onChanged: (v) => setState(() => _locRec = v)),
                    SizedBox(height: 10),
                    KdsCheckbox(label: "기분/날씨 자동 태깅", value: _autoTag, onChanged: (v) => setState(() => _autoTag = v)),
                    SizedBox(height: 12),
                Divider(color: KDS.espressoBlack, thickness: 1),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("아이콘 실행 모드", style: TextStyle(fontSize: KDS.fontXs, fontWeight: FontWeight.bold))
                ),
                SizedBox(height: 8),
                SizedBox(height: 12),
                Row(
                  children: [
                     _executionModeButton("원클릭", ExecutionMode.singleClick, Icons.touch_app),
                     SizedBox(width: 12),
                     _executionModeButton("더블클릭", ExecutionMode.doubleClick, Icons.ads_click),
                  ],
                ),
              ])
            ),
            SizedBox(height: 16),
            KdsWindow(
              title: "정보",
              child: Column(
                children: [
                  _infoRow("버전", "1.0.0"),
                  SizedBox(height: 8),
                  _infoRow("빌드", "20260311"),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ],
);
}

Widget _executionModeButton(String label, ExecutionMode mode, IconData icon) {
final currentMode = ref.watch(settingsProvider).executionMode;
final isSelected = currentMode == mode;

return Expanded(
  child: GestureDetector(
    onTap: () => ref.read(settingsProvider.notifier).setExecutionMode(mode),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? KDS.mochaBrown : KDS.creamDark,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: KDS.espressoBlack, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: isSelected ? KDS.cream : KDS.espressoBlack, size: 28),
          SizedBox(height: 8),
          Text(
            label, 
            style: TextStyle(
              fontSize: KDS.fontSm, 
              fontWeight: FontWeight.bold,
              color: isSelected ? KDS.cream : KDS.espressoBlack
            )
          ),
          SizedBox(height: 4),
          Text(
            mode == ExecutionMode.singleClick ? "단일 선택 즉시 실행" : "선택 후 한 번 더 클릭",
            style: TextStyle(
              fontSize: 10, 
              color: isSelected ? KDS.cream.withValues(alpha: 0.8) : KDS.mochaBrown
            )
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: KDS.fontXs, color: KDS.mochaBrown)),
        Text(val, style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

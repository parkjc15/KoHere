import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/kds.dart';
import '../log/coffee_repository.dart';
import '../auth/auth_service.dart';
import '../auth/auth_gate_screen.dart';
import 'settings_screen.dart';

/// Mobile/12-Me Screen
/// 
/// 사용자 개인 프로필 및 통계 정보를 보여주는 화면입니다.
class MeScreen extends ConsumerStatefulWidget {
  // Desktop 탭 내부에 포함되는지 여부
  final bool embedded;
  final VoidCallback? onBack;
  
  const MeScreen({super.key, this.embedded = false, this.onBack});
  @override ConsumerState<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends ConsumerState<MeScreen> {
  @override
  Widget build(BuildContext context) {
    return widget.embedded 
      ? _body() 
      : Scaffold(backgroundColor: KDS.latteBeige, body: SafeArea(child: _body()));
  }

  Widget _body() {
    final allLogs = ref.watch(coffeeLogsProvider).where((l) => !l.isInTrash).toList();
    
    final totalLogs = allLogs.length;
    final uniqueCafes = allLogs.map((l) => l.cafeName).toSet().length;
    final uniqueFolders = allLogs.map((l) => l.folderName).whereType<String>().toSet().length;

    return Column(children: [
      KdsHeader(
        title: "나",
        onBack: widget.onBack ?? (widget.embedded ? null : () => Navigator.pop(context)),
        trailing: IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          icon: Icon(Icons.settings, size: 20, color: KDS.espressoBlack),
        ),
      ),
      
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          KdsWindow(
            title: "프로필 · .coffee 사용자", 
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: KDS.creamDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: KDS.espressoBlack, width: 2),
                  ),
                  child: Icon(Icons.person, size: 28, color: KDS.mochaBrown),
                ),
                SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("모카트래블러_27", style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text("mocha_traveler@kohere.app", style: TextStyle(fontSize: KDS.fontXs, color: KDS.mochaBrown)),
                  SizedBox(height: 2),
                  Text("가입일: 2025.01.15", style: TextStyle(fontSize: 12, color: KDS.gray)),
                ])),
              ]),
              SizedBox(height: 10),
              KdsButton(label: "프로필 편집", style: KdsButtonStyle.brown, onTap: () {}),
              SizedBox(height: 10),
              KdsButton(label: "닉네임 변경", onTap: () {}),
            ])
          ),
          SizedBox(height: 12),
          
          KdsWindow(
            title: "나의 .coffee 아카이브", 
            child: Column(children: [
              _statRow("방문 카페", "$uniqueCafes"),
              SizedBox(height: 8),
              _statRow("작성 로그", "$totalLogs"),
              SizedBox(height: 8),
              _statRow("지역 폴더", "$uniqueFolders"),
            ])
          ),
          SizedBox(height: 12),
          
          KdsWindow(
            title: "공유 & 백업", 
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              KdsButton(label: "💾 플로피 QR 공유", style: KdsButtonStyle.brown, onTap: () {}),
              SizedBox(height: 10),
              KdsButton(label: "📦 .coffee 백업", onTap: () {}),
            ])
          ),
          SizedBox(height: 24),
          KdsButton(
            label: "로그아웃", 
            style: KdsButtonStyle.cream, 
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
              if (mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthGateScreen()),
                  (route) => false,
                );
              }
            }
          ),
          SizedBox(height: 32),
        ]),
      )),
    ]);
  }

  Widget _statRow(String label, String val) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: KDS.fontXs, color: KDS.mochaBrown)),
      Text(val, style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold)),
    ]);
  }
}

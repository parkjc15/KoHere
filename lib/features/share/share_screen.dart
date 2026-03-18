import 'package:flutter/material.dart';
import '../../core/theme/kds.dart';

/// Mobile/10-Share Screen
/// 
/// 나의 커피 활동 내역(지도, 로그)을 다른 사용자에게 공유하는 화면입니다.
/// 클래식한 '플로피 디스크' 디자인을 메인 비주얼로 사용하며, 
/// QR 코드를 통해 데이터를 전달하거나 이미지/링크 형태로 공유할 수 있습니다.
class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KDS.latteBeige,
      body: SafeArea(child: Column(children: [
        // 상단 헤더
        KdsHeader(title: "공유"),
        
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(children: [
            
            // ── FloppyDisk (공유용 시각적 카드) ──
            Container(
              width: 280, height: 300,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              decoration: BoxDecoration(
                color: KDS.espressoBlack,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: KDS.mochaBrown, width: 2),
              ),
              child: Column(children: [
                // 플로피 디스크 상단 라벨 (제목 및 날짜)
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: KDS.cream, borderRadius: BorderRadius.circular(4)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("나의 커피 지도", style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold)),
                    Text("2025.03", style: TextStyle(fontSize: KDS.fontXs, color: KDS.mochaBrown)),
                  ]),
                ),
                SizedBox(height: 12),
                
                // 디스크 디자인용 장식물 (금속 셔터 형상)
                Container(width: 60, height: 8, decoration: BoxDecoration(color: KDS.grayDark, borderRadius: BorderRadius.circular(2))),
                SizedBox(height: 12),
                
                // ── QR Area (스캔 시 지도 데이터 연결) ──
                Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(color: KDS.cream, borderRadius: BorderRadius.circular(4)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(color: KDS.white, border: Border.all(color: KDS.espressoBlack, width: 2)),
                      // 실제 QR 코드 생성 위젯이 들어갈 자리 (현재는 아이콘 대체)
                      child: Icon(Icons.qr_code, size: 60, color: KDS.espressoBlack),
                    ),
                    SizedBox(height: 8),
                    Icon(Icons.coffee, size: 20, color: KDS.mochaBrown),
                  ]),
                ),
                
                const Spacer(),
                Text("1.44 MB — Kohere Disk", style: TextStyle(fontSize: 10, color: KDS.gray)),
              ]),
            ),
            SizedBox(height: 20),
            
            // 안내 문구
            Text("플로피 디스크를 스캔하면\n나의 커피 지도를 공유할 수 있어요!", textAlign: TextAlign.center,
              style: TextStyle(fontSize: KDS.fontSm)),
            SizedBox(height: 20),
            
            // ── 공유 액션 버튼 리스트 ──
            KdsButton(label: "💾 이미지로 저장", style: KdsButtonStyle.brown, onTap: () {}),
            SizedBox(height: 8),
            KdsButton(label: "📎 링크 복사", onTap: () {}),
            SizedBox(height: 8),
            KdsButton(label: "📤 SNS 공유", onTap: () {}),
            SizedBox(height: 20),
            
            // 주의 사항 문구
            Text("공유 시 .coffee 로그와 방문 카페 지도가\n함께 전달됩니다.", textAlign: TextAlign.center,
              style: TextStyle(fontSize: KDS.fontXs, color: Color(0xFF999999))),
          ]),
        )),
      ])),
    );
  }
}

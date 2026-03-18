import 'package:flutter/material.dart';
import '../../core/theme/kds.dart';

/// Mobile/5-Terms Screen
/// 
/// 서비스 이용에 필요한 법적 약관 내용을 보여주는 화면입니다.
/// 가독성을 위해 'KdsWindow' 내부에 스크롤 가능한 텍스트 형태로 제공됩니다.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KDS.latteBeige,
      body: SafeArea(child: Column(children: [
        // 상단 헤더
        KdsHeader(title: "서비스 이용약관"),
        
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ── 약관 본문 윈도우 ──
            KdsWindow(
              title: "[전문] 서비스 이용약관", 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("제1조 (목적)", style: TextStyle(fontSize: KDS.fontXs, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('본 약관은 Kohere(이하 "서비스")의 이용과 관련하여 서비스 제공자와 이용자 간 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.',
                    style: TextStyle(fontSize: KDS.fontXs, color: KDS.gray)),
                  SizedBox(height: 8),
                  
                  Text("제2조 (서비스 제공)", style: TextStyle(fontSize: KDS.fontXs, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("서비스는 로컬 카페 기록, 지도 기반 탐색, 후기 작성 및 공유 기능을 제공합니다. 운영상 필요 시 기능의 전부 또는 일부를 변경할 수 있습니다.",
                    style: TextStyle(fontSize: KDS.fontXs, color: KDS.gray)),
                  SizedBox(height: 8),
                  
                  Text("제3조 (이용자 의무)", style: TextStyle(fontSize: KDS.fontXs, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("이용자는 타인의 권리를 침해하거나 허위/불법 정보를 등록해서는 안 되며, 관계 법령 및 본 약관을 준수해야 합니다.",
                    style: TextStyle(fontSize: KDS.fontXs, color: KDS.gray)),
                  SizedBox(height: 8),
                  
                  Text("제4조 (이용 제한)", style: TextStyle(fontSize: KDS.fontXs, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("운영 정책 위반, 서비스 안정성 저해, 권리 침해 행위가 확인되는 경우 사전 통지 후 일부 기능 제한 또는 계정 이용 정지를 할 수 있습니다.",
                    style: TextStyle(fontSize: KDS.fontXs, color: KDS.gray)),
                  SizedBox(height: 8),
                  
                  // 시행일 정보
                  Text("시행일: 2026-03-05", style: TextStyle(fontSize: KDS.fontXs, fontWeight: FontWeight.bold, color: KDS.mochaBrown)),
                ],
              )
            ),
            SizedBox(height: 12),
            
            // ── 확인/닫기 버튼 ──
            KdsButton(
              label: "확인", 
              style: KdsButtonStyle.brown, 
              onTap: () => Navigator.pop(context)
            ),
          ]),
        )),
      ])),
    );
  }
}

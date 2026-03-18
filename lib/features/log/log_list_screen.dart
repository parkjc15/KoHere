import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/kds.dart';
import 'coffee_repository.dart';
import 'coffee_log_screen.dart';

/// Mobile/8-LogList Screen
/// 
/// 저장된 커피 로그들을 지역(폴더)별로 모아보는 리스트 화면입니다.
/// 상단에서 지역을 선택하면 해당 지역의 로그들만 필터링되어 표시됩니다.
/// 각 로그는 'KdsWindow' 컴포넌트에 담겨 클래식한 카드 형태로 렌더링됩니다.
class LogListScreen extends ConsumerStatefulWidget {
  // Desktop 탭 내부에 포함되는지 여부 (true일 경우 별도의 Scaffold와 SafeArea 미사용)
  final bool embedded;
  final VoidCallback? onBack;
  
  const LogListScreen({super.key, this.embedded = false, this.onBack});
  @override ConsumerState<LogListScreen> createState() => _LogListScreenState();
}

class _LogListScreenState extends ConsumerState<LogListScreen> {
  // 현재 선택된 필터 인덱스 (폴더)
  int _sel = 0;
  
  // 지역 폴더 리스트
  final _folders = ["📁 성수", "📁 합정", "📁 연남", "📁 전체"];

  @override
  Widget build(BuildContext context) {
    // 임베디드 모드면 바로 본체 위젯 반환, 아니면 Scaffold로 감싸서 독립 화면으로 동작
    return widget.embedded 
      ? _body() 
      : Scaffold(backgroundColor: KDS.latteBeige, body: SafeArea(child: _body()));
  }

  /// 화면의 핵심 콘텐츠 위젯
  Widget _body() {
    // 모든 로그 감시 (상태 변화 시 자동 리빌드)
    final allLogs = ref.watch(coffeeLogsProvider);
    
    // 선택된 지역에 따라 데이터 필터링 (휴지통에 없는 것만 표시)
    final filteredLogs = allLogs.where((log) {
      if (log.isInTrash) return false;
      if (_sel == 3) return true; // '전체'
      final loc = ["성수", "합정", "연남"][_sel];
      return log.folderName == loc;
    }).toList();

    return Column(children: [
      // ── 상단 헤더 ──
      KdsHeader(
        title: "${_folders[_sel].replaceAll("📁 ", "")} 로그",
        onBack: widget.onBack ?? (widget.embedded ? null : () => Navigator.pop(context)),
        // 우상단 '+' 버튼 클릭 시 새 로그 작성 화면으로 이동
        trailing: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoffeeLogScreen())),
          child: Icon(Icons.add, size: 20, color: KDS.espressoBlack),
        ),
      ),
      
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // ── 상단 지역 폴더(필터) 행 ──
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(
            children: List.generate(_folders.length, (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _sel = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: _sel == i ? KDS.mochaBrown : KDS.cream,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: KDS.espressoBlack, width: 2),
                  ),
                  child: Text(_folders[i], style: TextStyle(
                    
                    fontSize: KDS.fontXs, 
                    color: _sel == i ? KDS.cream : KDS.espressoBlack
                  )),
                ),
              ),
            )),
          )),
          SizedBox(height: 10),
          
          // ── 로그 데이터 유무에 따른 화면 처리 ──
          if (filteredLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(children: [
                Icon(Icons.folder_open, size: 48, color: KDS.creamDark),
                SizedBox(height: 12),
                Text("기록된 .coffee 로그가 없어요.\n새로운 기록을 남겨보세요.", textAlign: TextAlign.center,
                  style: TextStyle(fontSize: KDS.fontXs, color: KDS.gray)),
              ]),
            )
          else
            // ── 필터링된 로그 카드 리스트 ──
            ...filteredLogs.map((log) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: KdsWindow(
                title: "${log.cafeName} — ${DateFormat('MM.dd').format(log.createdAt)}", 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 메타 정보 (날씨/기분, 분위기)
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text("${log.weather} · ${log.mood}", style: TextStyle(fontSize: KDS.fontXs, color: KDS.mochaBrown)),
                      Text(log.ambiance, style: TextStyle(fontSize: KDS.fontXs, color: KDS.mochaBrown)),
                    ]),
                    SizedBox(height: 8),
                    
                    // 메뉴 정보
                    Text("🍵 ${log.menu}", style: TextStyle(fontSize: 12)),
                    SizedBox(height: 4),
                    
                    // 간단한 메모 내용
                    if (log.memo.isNotEmpty)
                      Text(log.memo, style: TextStyle(fontSize: KDS.fontXs, color: KDS.gray)),
                  ],
                )
              ),
            )),
        ]),
      )),
    ]);
  }
}

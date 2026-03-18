import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/log/coffee_repository.dart';

final regionalFoldersProvider = Provider<List<String>>((ref) {
  final logs = ref.watch(coffeeLogsProvider);
  
  // 쓰레기통에 있지 않은 로그들 중 존재하는 지역(folderName) 추출
  final regions = logs
      .where((log) => !log.isInTrash && log.folderName != null)
      .map((log) => log.folderName!)
      .toSet()
      .toList();
      
  return regions;
});

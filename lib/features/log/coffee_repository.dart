import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import 'coffee_log.dart';
import '../auth/auth_service.dart';

/// CoffeeLogRepository
/// 
/// 로컬 데이터베이스(Hive)와의 직접적인 상호작용을 담당합니다.
/// 데이터의 CRUD(생성, 읽기, 수정, 삭제) 로직을 관리합니다.
class CoffeeLogRepository {
  final String? userId;
  static const String _baseBoxName = 'coffee_logs';

  CoffeeLogRepository({this.userId});

  String get _boxName => userId != null ? '${_baseBoxName}_$userId' : _baseBoxName;

  // 데이터베이스 초기화
  bool _isInitialized = false;
  Future<void> init() async {
    if (_isInitialized) return;
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
    _isInitialized = true;
  }

  // 데이터베이스 초기화 여부 확인
  bool get isInitialized => _isInitialized;

  // 데이터 열람을 위한 상자(Box) 접근
  Box get _box {
    if (!_isInitialized) throw StateError("Repository not initialized. Call init() first.");
    return Hive.box(_boxName);
  }

  // 모든 로그 목록을 최신순으로 가져오기
  List<CoffeeLog> getAllLogs() {
    return _box.values.map((e) => CoffeeLog.fromMap(Map<String, dynamic>.from(e))).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // 새 로그 추가
  Future<void> addLog({
    required String cafeName,
    required String menu,
    required String weather,
    required String mood,
    required String ambiance,
    required String memo,
    String? imagePath,
    String? folderName,
  }) async {
    final id = const Uuid().v4();
    final log = CoffeeLog(
      id: id,
      cafeName: cafeName,
      menu: menu,
      weather: weather,
      mood: mood,
      ambiance: ambiance,
      memo: memo,
      createdAt: DateTime.now(),
      imagePath: imagePath,
      folderName: folderName,
    );
    await _box.put(id, log.toMap());
  }

  // 휴지통 상태 업데이트
  Future<void> updateTrashStatus(String id, bool isInTrash) async {
    final data = _box.get(id);
    if (data != null) {
      final log = CoffeeLog.fromMap(Map<String, dynamic>.from(data));
      await _box.put(id, log.copyWith(isInTrash: isInTrash).toMap());
    }
  }

  // 로그 완전 삭제
  Future<void> deleteLog(String id) async {
    await _box.delete(id);
  }

  // 휴지통 비우기
  Future<void> emptyTrash() async {
    final logsInTrash = getAllLogs().where((log) => log.isInTrash);
    for (var log in logsInTrash) {
      await _box.delete(log.id);
    }
  }
}

// 전역 레포지토리 프로바이더 - 사용자 ID가 바뀌면 새로 생성됨
final coffeeRepositoryProvider = Provider((ref) {
  final user = ref.watch(authStateProvider).value;
  return CoffeeLogRepository(userId: user?.uid);
});

// 전역 로그 리스트 프로바이더 (상태 관리용)
final coffeeLogsProvider = StateNotifierProvider<CoffeeLogsNotifier, List<CoffeeLog>>((ref) {
  final repository = ref.watch(coffeeRepositoryProvider);
  return CoffeeLogsNotifier(repository);
});

/// CoffeeLogsNotifier
/// 
/// 앱의 UI에서 사용하는 로그 리스트 상태를 관리하고 업데이트합니다.
class CoffeeLogsNotifier extends StateNotifier<List<CoffeeLog>> {
  final CoffeeLogRepository _repository;

  CoffeeLogsNotifier(this._repository) : super([]) {
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    try {
      if (!_repository.isInitialized) {
        await _repository.init();
      }
      if (mounted) {
        loadLogs();
      }
    } catch (_) {
      // 초기화 실패 시 무시
    }
  }

  // 데이터베이스에서 상태 동기화
  void loadLogs() {
    if (!_repository.isInitialized) return;
    state = _repository.getAllLogs();
  }

  // 로그 추가 액션
  Future<void> addLog({
    required String cafeName,
    required String menu,
    required String weather,
    required String mood,
    required String ambiance,
    required String memo,
    String? imagePath,
    String? folderName,
  }) async {
    await _repository.addLog(
      cafeName: cafeName,
      menu: menu,
      weather: weather,
      mood: mood,
      ambiance: ambiance,
      memo: memo,
      imagePath: imagePath,
      folderName: folderName,
    );
    loadLogs();
  }

  // 휴지통으로 이동
  Future<void> moveToTrash(String id) async {
    await _repository.updateTrashStatus(id, true);
    loadLogs();
  }

  // 휴지통에서 복원
  Future<void> restoreFromTrash(String id) async {
    await _repository.updateTrashStatus(id, false);
    loadLogs();
  }

  // 휴지통 비우기
  Future<void> emptyTrash() async {
    await _repository.emptyTrash();
    loadLogs();
  }

  // 영구 삭제
  Future<void> deletePermanently(String id) async {
    await _repository.deleteLog(id);
    loadLogs();
  }
}

/// CoffeeLog Model
/// 
/// 커피 기록 한 건에 대한 데이터를 담는 모델 클래스입니다.
/// 카페 이름, 메뉴, 지역, 날씨, 기분, 분위기 등 모든 로그 정보를 포함합니다.
class CoffeeLog {
  final String id;
  final String cafeName;
  final String menu;      // 추가: 마신 메뉴
  final String weather;
  final String mood;
  final String ambiance;  // 추가: 카페 분위기
  final String memo;
  final DateTime createdAt;
  final String? folderName; // 지역명 (성수, 합정 등)
  final bool isInTrash;
  final String? imagePath;

  CoffeeLog({
    required this.id,
    required this.cafeName,
    required this.menu,
    required this.weather,
    required this.mood,
    required this.ambiance,
    required this.memo,
    required this.createdAt,
    this.folderName,
    this.isInTrash = false,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cafeName': cafeName,
      'menu': menu,
      'weather': weather,
      'mood': mood,
      'ambiance': ambiance,
      'memo': memo,
      'createdAt': createdAt.toIso8601String(),
      'folderName': folderName,
      'isInTrash': isInTrash,
      'imagePath': imagePath,
    };
  }

  factory CoffeeLog.fromMap(Map<dynamic, dynamic> map) {
    return CoffeeLog(
      id: map['id'] as String,
      cafeName: map['cafeName'] as String,
      menu: map['menu'] as String? ?? '',
      weather: map['weather'] as String,
      mood: map['mood'] as String,
      ambiance: map['ambiance'] as String? ?? '',
      memo: map['memo'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      folderName: map['folderName'] as String?,
      isInTrash: map['isInTrash'] as bool? ?? false,
      imagePath: map['imagePath'] as String?,
    );
  }

  CoffeeLog copyWith({
    bool? isInTrash, 
    String? imagePath, 
    String? folderName,
    String? cafeName,
    String? menu,
    String? weather,
    String? mood,
    String? ambiance,
    String? memo,
  }) {
    return CoffeeLog(
      id: id,
      cafeName: cafeName ?? this.cafeName,
      menu: menu ?? this.menu,
      weather: weather ?? this.weather,
      mood: mood ?? this.mood,
      ambiance: ambiance ?? this.ambiance,
      memo: memo ?? this.memo,
      createdAt: createdAt,
      folderName: folderName ?? this.folderName,
      isInTrash: isInTrash ?? this.isInTrash,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

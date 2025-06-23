import 'package:flame/components.dart';
import '../mygame.dart';

class EnemySpawner extends Component with HasGameRef<MyGame> {
  final Vector2 spawnPosition;
  final double spawnInterval;
  final PositionComponent Function() createEnemy;

  double _timer = 0;

  EnemySpawner({
    required this.spawnPosition,
    required this.createEnemy,
    this.spawnInterval = 2.0,
  });

  @override
  void update(double dt) {
    super.update(dt);

    // ✅ إيقاف التوليد إذا وصلنا للعدد المطلوب
    if (gameRef.enemiesSpawned >= gameRef.totalEnemiesToSpawn) return;

    _timer += dt;

    if (_timer >= spawnInterval) {
      _spawnEnemy();
      _timer = 0;
    }
  }

  void _spawnEnemy() {
    final enemy = createEnemy();
    enemy.position = spawnPosition.clone();
    gameRef.add(enemy);

    gameRef.enemiesSpawned++; // ✅ تتبع عدد الأعداء
  }
}

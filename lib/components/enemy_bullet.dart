import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:study/mygame.dart';
import 'player.dart';

class EnemyBullet extends SpriteComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  final Vector2 direction;
  final double speed = 250.0;

  EnemyBullet({required this.direction})
      : super(size: Vector2(24, 24), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('bullet.png');
    add(CircleHitbox()); // ✅ لتفعيل التصادم
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * speed * dt;

    // ✅ إزالة الطلقة إذا خرجت من الشاشة
    if (position.x < 0 ||
        position.x > gameRef.size.x ||
        position.y < 0 ||
        position.y > gameRef.size.y) {
      removeFromParent();
    }
  }

  @override
void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  super.onCollision(intersectionPoints, other);

  if (other is Player && !other.isDead) {
    other.takeDamage(1);
    removeFromParent();
  }
}

}

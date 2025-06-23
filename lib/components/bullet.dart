import 'dart:math';
import 'package:flame/components.dart';
import 'package:study/mygame.dart';
import 'enemy.dart';
import 'slime.dart';

class Bullet extends SpriteComponent with HasGameRef<MyGame> {
  final SpriteComponent target;
  final Vector2 start;
  final double speed = 300.0;

  Bullet({required this.target, required this.start})
      : super(size: Vector2(50, 32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('bullet.png');
    position = start.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!target.isMounted) {
      removeFromParent();
      return;
    }

    final direction = (target.position - position);
    final normalized = direction.normalized();

    position += normalized * speed * dt;
    angle = atan2(direction.y, direction.x);

    if (position.distanceTo(target.position) < 10) {
      // ✅ تأكد من نوع العدو قبل استدعاء startDeath()
      if (target is Enemy) {
        (target as Enemy).startDeath();
      } else if (target is EnemyMelee) {
        // يمكنك هنا تنفيذ منطق موت الميلي إن أردت، أو فقط removeFromParent()
        target.removeFromParent();
      }

      removeFromParent();
    }
  }
}

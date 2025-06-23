import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:study/mygame.dart';
import 'enemy_bullet.dart';

class Enemy extends SpriteAnimationComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  final double speed = 80.0;
  bool isDying = false;
  bool isShooting = false;

  double deathTimer = 0.0;
  double shootCooldown = 0.0;

  late SpriteAnimation walkAnimation;
  late SpriteAnimation shootAnimation;
  late Sprite whiteSprite;

  Enemy() : super(size: Vector2(96, 96), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    walkAnimation = SpriteAnimation.spriteList([
      await gameRef.loadSprite('enemy_1.png'),
      await gameRef.loadSprite('enemy_2.png'),
      await gameRef.loadSprite('enemy_3.png'),
    ], stepTime: 0.15);

    shootAnimation = SpriteAnimation.spriteList(
      [
        await gameRef.loadSprite('enemy_shoot_1.png'),
        await gameRef.loadSprite('enemy_shoot_2.png'),
        await gameRef.loadSprite('enemy_shoot_3.png'),
      ],
      stepTime: 0.1,
      loop: false,
    );

    whiteSprite = await gameRef.loadSprite('enemy_white.png');
    animation = walkAnimation;

    add(CircleHitbox()); // ✅ لإضافة التصادم
  }

  @override
  void update(double dt) {
    super.update(dt);

    final player = gameRef.player;
    if (player == null || !player.isMounted || player.isDead) return;

    if (isDying) {
      deathTimer += dt;
      if (deathTimer > 0.2) {
        opacity -= dt * 2;
        if (opacity <= 0) {
          removeFromParent();
        }
      }
      return;
    }

    final direction = (player.position - position).normalized();
    final distance = player.position.distanceTo(position);

    // إطلاق النار
    if (distance < 100) {
      shootCooldown -= dt;

      if (shootCooldown <= 0 && !isShooting) {
        shootCooldown = 1.5;
        isShooting = true;

        animation = shootAnimation;
        animationTicker?.reset();

        final bullet = EnemyBullet(direction: direction)
          ..position = position.clone();
        gameRef.add(bullet);
      }
    } else if (!isShooting) {
      position += direction * speed * dt;
    }

    // الرجوع لأنيميشن المشي
    if (isShooting && (animationTicker?.done() ?? false)) {
      animation = walkAnimation;
      isShooting = false;
    }

    // الهجوم القريب
    if (distance < 30 && !isDying) {
      player.takeDamage(4);
      startDeath();
    }
  }

  void startDeath() {
    if (isDying) return;

    isDying = true;
    animation = SpriteAnimation.spriteList([
      whiteSprite,
    ], stepTime: double.infinity);
  }
}

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:study/mygame.dart';

class EnemyMelee extends SpriteAnimationComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  final double speed = 80.0;
  bool isAttacking = false;
  bool isDying = false;
  double deathTimer = 0.0;

  late SpriteAnimation walkAnimation;
  late SpriteAnimation attackAnimation;
  late SpriteAnimation deathAnimation;

  double attackCooldown = 0.0;

  EnemyMelee() : super(size: Vector2(96, 96), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    walkAnimation = SpriteAnimation.spriteList([
      await gameRef.loadSprite('slime-move-0.png'),
      await gameRef.loadSprite('slime-move-1.png'),
      await gameRef.loadSprite('slime-move-2.png'),
    ], stepTime: 0.15);

    attackAnimation = SpriteAnimation.spriteList(
      [
        await gameRef.loadSprite('slime-attack-0.png'),
        await gameRef.loadSprite('slime-attack-1.png'),
        await gameRef.loadSprite('slime-attack-2.png'),
      ],
      stepTime: 0.12,
      loop: true,
    );

    deathAnimation = SpriteAnimation.spriteList([
      await gameRef.loadSprite(
        'slime-dead.png',
      ), // تأكد أنك أضفت هذه الصورة في الأصول
    ], stepTime: double.infinity);

    animation = walkAnimation;
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDying) {
      deathTimer += dt;
      opacity -= dt * 2;
      if (opacity <= 0) {
        removeFromParent();
      }
      return;
    }

    final player = gameRef.player;
    if (player == null || !player.isMounted || player.isDead) return;

    final distance = player.position.distanceTo(position);
    scale.x = player.position.x < position.x ? -1 : 1;
    attackCooldown -= dt;

    if (distance < 30) {
      if (!isAttacking) {
        animation = attackAnimation;
        isAttacking = true;
      }

      if (attackCooldown <= 0) {
        player.takeDamage(4);
        attackCooldown = 0.36;
      }
    } else {
      if (isAttacking) {
        animation = walkAnimation;
        isAttacking = false;
      }

      final direction = (player.position - position).normalized();
      position += direction * speed * dt;
    }
  }

  void startDeath() {
    if (isDying) return;
    isDying = true;
    animation = deathAnimation;
  }
}

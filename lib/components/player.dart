import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:study/mygame.dart';
import 'package:study/overlays/game_over.dart';
import 'bullet.dart';
import 'enemy.dart';
import 'slime.dart';

class Player extends SpriteComponent with HasGameRef<MyGame>, CollisionCallbacks {
  int ammo = 30;
  int health = 100;
  bool isDead = false;

  Player()
      : super(
          size: Vector2(96, 96),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('player.png');
    position = gameRef.size / 2;
    add(CircleHitbox());
  }

  void shootNearestEnemy(MyGame game) {
    if (ammo <= 0 || isDead) return;

    final enemies = game.children.where((c) =>
        (c is Enemy || c is EnemyMelee) &&
        (c as PositionComponent).isMounted &&
        !(c as dynamic).isDying);

    if (enemies.isEmpty) return;

    final nearest = enemies.reduce((a, b) {
      final distA = (a as PositionComponent).position.distanceTo(position);
      final distB = (b as PositionComponent).position.distanceTo(position);
      return distA < distB ? a : b;
    }) as SpriteComponent;

    final gun = RectangleComponent(
      size: Vector2(20, 10),
      anchor: Anchor.center,
      position: position,
    );

    final bullet = Bullet(target: nearest, start: gun.absoluteCenter);
    game.add(bullet);

    ammo--;
    game.ammoNotifier.value = ammo;
    FlameAudio.play('laser.mp3', volume: 0.4);
  }

  void takeDamage(int damage) {
    if (isDead) return;

    health -= damage;

    if (health <= 0) {
      die();
    }
  }

  void die() {
    if (isDead) return;

    isDead = true;
    removeFromParent();

    // ✅ ممكن تضيف انتقال إلى شاشة الخسارة هنا لو أردت
    Future.delayed(const Duration(milliseconds: 300), () {
      if (gameRef.buildContext.mounted) {
        Navigator.of(gameRef.buildContext).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const GameOverScreen(didWin: false),
          ),
        );
      }
    });
  }
}

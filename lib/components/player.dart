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
          size: Vector2(96, 96), // Ensure this size is appropriate for your sprite
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    debugPrint("[Player] onLoad started.");
    try {
      sprite = await gameRef.loadSprite('player.png');
      debugPrint("[Player] Player sprite loaded successfully.");
    } catch (e) {
      debugPrint("[Player] Error loading player sprite: $e");
      // Optionally, load a placeholder sprite or handle the error visually
    }
    position = gameRef.size / 2;
    add(CircleHitbox());
    debugPrint("[Player] Player hitbox added and position set to ${position}. onLoad finished.");
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
    if (isDead || gameRef.isNavigatingToGameOver) return; // Check gameRef flag too

    isDead = true;
    gameRef.isNavigatingToGameOver = true; // Set game-level flag
    debugPrint("[Player] Player died. Attempting to navigate to GameOverScreen (Lose).");

    // It's generally safer for the game to handle its own removal or state changes
    // rather than the player removing itself and then triggering navigation.
    // However, for now, let's keep removeFromParent and see.
    // A slight delay can help ensure the current game loop tick completes.
    Future.delayed(const Duration(milliseconds: 50), () { // Shorter delay
      try {
        removeFromParent(); // Remove player from game
      } catch (e) {
        debugPrint("[Player] Error removing player from parent: $e");
      }

      if (gameRef.buildContext.mounted) {
        Navigator.of(gameRef.buildContext).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const GameOverScreen(didWin: false),
          ),
        ).then((_) {
          debugPrint("[Player] Navigation to GameOver (Lose) complete. Pausing game.");
          gameRef.pauseEngine(); // Pause engine after navigation
          // Game-level cleanup (like removing other entities) should ideally be handled in MyGame
          // if further cleanup is needed post player death navigation.
        }).catchError((e) {
          debugPrint("[Player] Error during navigation to GameOver (Lose): $e");
          gameRef.isNavigatingToGameOver = false; // Reset flag on error
        });
      } else {
        debugPrint("[Player] Died: gameRef.buildContext not mounted, cannot navigate.");
        gameRef.isNavigatingToGameOver = false; // Reset flag
      }
    });
  }
}

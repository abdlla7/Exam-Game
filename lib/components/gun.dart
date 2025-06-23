import 'package:flame/components.dart';
import 'package:study/mygame.dart';


class Gun extends SpriteComponent with HasGameRef<MyGame> {
  Gun() : super(size: Vector2(72, 63)) {
    anchor = Anchor.center;
    angle = -0.45;
  }
  

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('gun.png');
    position = Vector2(50, 60); 
    faceDirection(bool faceLeft) {
      scale.x = faceLeft ? -1 : 1;
    }
  }
  



  void faceDirection(bool faceLeft) {}
}

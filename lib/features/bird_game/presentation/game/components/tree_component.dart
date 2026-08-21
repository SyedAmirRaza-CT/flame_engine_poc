import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class TreeComponent extends SpriteComponent
    with CollisionCallbacks {
  TreeComponent({
    required Vector2 position,
    Vector2? size,
  }) : super(
    position: position,
    size: size ?? Vector2.all(100),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(
      'environment/tree.png',
    );

    // Collision area is only around the trunk.
    //
    // We don't want the bird to collide with
    // the transparent/top part of the tree image.
    add(
      RectangleHitbox(
        size: Vector2(
          size.x * 0.25,
          size.y * 0.35,
        ),
        position: Vector2(
          size.x * 0.375,
          size.y * 0.55,
        ),
      ),
    );
  }
}
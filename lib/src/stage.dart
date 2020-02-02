import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:flutter/material.dart';

typedef void SceneCreatedCallback(Scene scene);

class Stage extends StatefulWidget {
  Stage({
    Key key,
    this.interactive = true,
    this.onSceneCreated,
    this.children = const <Actor>[],
  }) : super(key: key);

  final bool interactive;
  final SceneCreatedCallback onSceneCreated;
  final List<Actor> children;

  @override
  _StageState createState() => _StageState();
}

class _StageState extends State<Stage> {
  Scene scene;
  Offset _lastFocalPoint;

  void _handleScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.localFocalPoint;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale != 1.0) {
      scene.camera.position.scale(1.0 + (1.0 - details.scale) * 0.01);
    }
    scene.camera.trackBall(_lastFocalPoint, details.localFocalPoint, 1.5);
    _lastFocalPoint = details.localFocalPoint;
    setState(() {});
  }

  /// Transform from homonegenous coordinates to the normalized device coordinates，and then transform to viewport.
  void applyViewportTransform(Vector4 v, double viewportWidth, double viewportHeight) {
    final storage = v.storage;
    //perspective division,
    final double w = storage[3];
    final double x = storage[0] / w;
    final double y = storage[1] / w;
    final double z = storage[2] / w;
    storage[0] = x;
    storage[1] = y;
    storage[2] = z;
  }

  void transformActor(List<Actor> list, Actor actor, Matrix4 transform) {
    final Matrix4 _transform = transform * actor.transform;
    final Vector4 v = Vector4.identity();
    v.applyMatrix4(_transform);
    applyViewportTransform(v, scene.camera.viewportWidth, scene.camera.viewportHeight);
    v.xyz.copyInto(actor.transformedPosition);
    _transform.copyInto(actor.transformedMatrix);
    list.add(actor);

    for (int i = 0; i < actor.children.length; i++) {
      transformActor(list, actor.children[i], _transform);
    }
  }

  @override
  void didUpdateWidget(Stage oldWidget) {
    super.didUpdateWidget(oldWidget);
    scene._updateChildren(widget.children);
  }

  @override
  void initState() {
    super.initState();
    scene = Scene(onUpdate: () => setState(() {}), children: widget.children);
    if (widget.onSceneCreated != null) widget.onSceneCreated(scene);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        scene.camera.viewportWidth = constraints.maxWidth;
        scene.camera.viewportHeight = constraints.maxHeight;
        final List<Actor> children = List<Actor>();
        final Matrix4 transform = scene.camera.projectionMatrix * scene.camera.transform;
        transformActor(children, scene.world, transform);

        children.sort((Actor a, Actor b) {
          final double az = a.transformedPosition.z;
          final double bz = b.transformedPosition.z;
          if (bz > az) return 1;
          if (bz < az) return -1;
          return 0;
        });

        List<Widget> widgets = List<Widget>();
        for (int i = 0; i < children.length; i++) {
          final Actor child = children[i];
          final newChild = Positioned(
            left: constraints.maxWidth / 2 - child.width * child.orgin.dx,
            top: constraints.maxHeight / 2 - child.height * child.orgin.dy,
            width: child.width,
            height: child.height,
            child: Transform(
              origin: Offset(child.width * child.orgin.dx, child.height * child.orgin.dy),
              transform: child.transformedMatrix,
              child: child.widget,
            ),
          );
          widgets.add(newChild);
        }

        if (widget.interactive) {
          return GestureDetector(
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            child: Stack(children: widgets),
          );
        }
        return Stack(children: widgets);
      },
    );
  }
}

class Scene {
  Scene({VoidCallback onUpdate, List<Actor> children}) {
    this._onUpdate = onUpdate;
    camera = Camera();
    world = Actor(children: children);
  }

  Camera camera;
  Actor world;
  VoidCallback _onUpdate;

  void _updateChildren(List<Actor> children) {
    world = Actor(children: children);
  }

  void update() {
    if (_onUpdate != null) _onUpdate();
  }
}

class Actor {
  Actor({
    this.name,
    Vector3 position,
    Vector3 rotation,
    Vector3 scale,
    this.orgin = const Offset(0.5, 0.5),
    this.width = 100,
    this.height = 100,
    this.widget,
    this.parent,
    List<Actor> children,
  }) {
    if (position != null) position.copyInto(this.position);
    if (rotation != null) rotation.copyInto(this.rotation);
    if (scale != null) scale.copyInto(this.scale);
    updateTransform();
    if (children != null) this.children.addAll(children);
    for (Actor child in this.children) {
      child.parent = this;
    }
  }

  /// The name of this actor.
  String name;

  /// The local position of this actor relative to the parent. Default is Vector3(0.0, 0.0, 0.0). updateTransform after you change the value.
  final Vector3 position = Vector3(0.0, 0.0, 0.0);

  /// The local rotation of this actor relative to the parent. Default is Vector3(0.0, 0.0, 0.0). updateTransform after you change the value.
  final Vector3 rotation = Vector3(0.0, 0.0, 0.0);

  /// The local scale of this actor relative to the parent. Default is Vector3(1.0, 1.0, 1.0). updateTransform after you change the value.
  final Vector3 scale = Vector3(1.0, 1.0, 1.0);

  /// The local orgin of this actor. Default is Offset(0.5, 0.5).
  final Offset orgin;

  // The width of widget.
  double width;

  // The height of widget.
  double height;

  /// The parent of this actor.
  Actor parent;

  Widget widget;
  final List<Actor> children = List<Actor>();

  /// The transformation of the actor in the scene, including position, rotation, and scaling.
  final Matrix4 transform = Matrix4.identity();

  final Vector3 transformedPosition = Vector3(0.0, 0.0, 0.0);
  final Matrix4 transformedMatrix = Matrix4.identity();

  void updateTransform() {
    final Matrix4 m = Matrix4.compose(position, Quaternion.euler(radians(rotation.y), radians(rotation.x), radians(rotation.z)), scale);
    transform.setFrom(m);
  }

  /// Find a child matching the name
  Actor find(String name) {
    for (Actor child in children) {
      if (name == child.name) return child;
      final Actor result = child.find(name);
      if (result != null) return result;
    }
    return null;
  }
}

class Camera {
  Camera({
    Vector3 position,
    Vector3 target,
    Vector3 up,
    this.fov = 60.0,
    this.near = 0.1,
    this.far = 1000,
    this.zoom = 1.0,
    this.viewportWidth = 100.0,
    this.viewportHeight = 100.0,
  }) {
    if (position != null) position.copyInto(this.position);
    if (target != null) target.copyInto(this.target);
    if (up != null) up.copyInto(this.up);
    updateTransform();
  }

  final Vector3 position = Vector3(0.0, 0.0, -10.0);
  final Vector3 target = Vector3(0.0, 0.0, 0.0);
  final Vector3 up = Vector3(0.0, 1.0, 0.0);
  double fov;
  double near;
  double far;
  double zoom;
  double viewportWidth;
  double viewportHeight;

  double get aspectRatio => viewportWidth / viewportHeight;

  final Matrix4 transform = Matrix4.identity();

  void updateTransform() {
    transform.setFrom(makeViewMatrix(position, target, up));
  }

  Matrix4 get projectionMatrix {
    // from https://github.com/wmleler/thematrix
    return Matrix4(
      1.0, 0.0, 0.0, 0, //
      0.0, 1.0, 0.0, 0, //
      0.0, 0.0, -1.0, -0.002, //
      0.0, 0.0, 0.0, 1.0,
    )..scale(zoom);
  }

  void trackBall(Offset from, Offset to, [double sensitivity = 1.0]) {
    final double deltaX = -(to.dx - from.dx) * sensitivity / (viewportWidth * 0.5);
    final double deltaY = -(to.dy - from.dy) * sensitivity / (viewportHeight * 0.5);
    Vector3 moveDirection = Vector3(deltaX, deltaY, 0);
    final double angle = moveDirection.length;
    if (angle > 0) {
      Vector3 _eye = position - target;
      Vector3 eyeDirection = _eye.normalized();
      Vector3 upDirection = up.normalized();
      Vector3 sidewaysDirection = upDirection.cross(eyeDirection).normalized();
      upDirection.scale(deltaY);
      sidewaysDirection.scale(deltaX);
      moveDirection = upDirection + sidewaysDirection;
      Vector3 axis = moveDirection.cross(_eye).normalized();
      Quaternion q = Quaternion.axisAngle(axis, angle);
      q.rotate(position);
      q.rotate(up);
      updateTransform();
    }
  }
}

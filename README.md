# Flutter Stage

[![pub package](https://img.shields.io/pub/v/flutter_stage.svg)](https://pub.dev/packages/flutter_stage)

A widget that positions its children in a 3D scene.

## Getting Started

Add flutter_stage as a dependency in your pubspec.yaml file.

```yaml
dependencies:
  flutter_stage: ^0.0.1
```

Import package.

```dart
import 'package:flutter_stage/flutter_stage.dart';
... ...
  
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stage(
        onSceneCreated: (Scene scene) {
          scene.camera.position.setFrom(Vector3(0, 0, 1000));
          scene.camera.updateTransform();
        },
        children: [
          Actor(
            position: Vector3(0, 0, 0),
            rotation: Vector3(0, 30, 0),
            children: [
              Actor(position: Vector3(0, 0, 300), rotation: Vector3(0, 0, 0), width: 600, height: 600, widget: Container(color: Colors.red.withOpacity(0.5))),
              Actor(position: Vector3(300, 0, 0), rotation: Vector3(0, 90, 0), width: 600, height: 600, widget: Container(color: Colors.green.withOpacity(0.5))),
              Actor(position: Vector3(0, 0, -300), rotation: Vector3(0, 180, 0), width: 600, height: 600, widget: Container(color: Colors.blue.withOpacity(0.5))),
              Actor(position: Vector3(-300, 0, 0), rotation: Vector3(0, 270, 0), width: 600, height: 600, widget: Container(color: Colors.yellow.withOpacity(0.5))),
              Actor(position: Vector3(0, -300, 0), rotation: Vector3(90, 0, 0), width: 600, height: 600, widget: Container(color: Colors.pink.withOpacity(0.5))),
              Actor(position: Vector3(0, 300, 0), rotation: Vector3(270, 0, 0), width: 600, height: 600, widget: Container(color: Colors.white.withOpacity(0.5)))
            ],
          ),
        ],
      ),
    );
  }
```

## Screenshot
![screenshot](https://github.com/zesage/flutter_stage/raw/master/resource/screenshot.gif)

[Flutter Clock Challenge submission](https://github.com/zesage/flutter_clock/tree/master/block_clock)


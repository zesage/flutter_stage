import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stage/flutter_stage.dart';
import 'package:intl/intl.dart';
import 'control.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Stage',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Flutter Stage Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/// Weather condition in English.
enum WeatherCondition {
  cloudy,
  foggy,
  rainy,
  snowy,
  sunny,
  thunderstorm,
  windy,
}

/// Temperature unit of measurement.
enum TemperatureUnit {
  celsius,
  fahrenheit,
}

class _MyHomePageState extends State<MyHomePage> {
  late Scene scene;
  String _location = 'Mountain View, CA';
  num _temperature = 22.0;
  WeatherCondition _weatherCondition = WeatherCondition.sunny;
  TemperatureUnit _unit = TemperatureUnit.celsius;

  ClockTimeControl _clockControl = ClockTimeControl();
  ClockHandControl _clockHandControl = ClockHandControl();

  /// Temperature unit of measurement with degrees.
  String get unitString {
    switch (_unit) {
      case TemperatureUnit.fahrenheit:
        return '°F';
      case TemperatureUnit.celsius:
      default:
        return '°C';
    }
  }

  num _convertFromCelsius(num degreesCelsius) {
    switch (_unit) {
      case TemperatureUnit.fahrenheit:
        return 32.0 + degreesCelsius * 9.0 / 5.0;
      case TemperatureUnit.celsius:
      default:
        return degreesCelsius;
    }
  }

  num _convertToCelsius(num degrees) {
    switch (_unit) {
      case TemperatureUnit.fahrenheit:
        return (degrees - 32.0) * 5.0 / 9.0;
      case TemperatureUnit.celsius:
      default:
        return degrees;
    }
  }

  /// Removes the enum type and returns the value as a String.
  String enumToString(Object e) => e.toString().split('.').last;

  Widget _enumMenu<T>(
      String label, T value, List<T> items, ValueChanged<T?> onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          onChanged: onChanged,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(enumToString(item!)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _textField(
      String currentValue, String label, ValueChanged<String>? onChanged) {
    return TextField(
      decoration: InputDecoration(
        hintText: currentValue,
        helperText: label,
      ),
      onChanged: onChanged,
    );
  }

  void _onSceneCreated(Scene scene) {
    this.scene = scene;
    scene.camera!.position.setFrom(Vector3(0, 0, 1000));
    scene.camera!.updateTransform();
  }

  Actor makeBlock(
      {required String name,
      required Vector3 position,
      required double size,
      required List<Actor> faces}) {
    final double radius = size / 2 - size * 0.0015;
    return Actor(name: name, position: position, children: [
      Actor(
          name: faces[0].name,
          position: Vector3(0, 0, radius),
          rotation: Vector3(0, 0, 0),
          width: size,
          height: size,
          widget: faces[0].widget,
          children: faces[0].children),
      Actor(
          name: faces[1].name,
          position: Vector3(radius, 0, 0),
          rotation: Vector3(0, 90, 0),
          width: size,
          height: size,
          widget: faces[1].widget,
          children: faces[1].children),
      Actor(
          name: faces[2].name,
          position: Vector3(0, 0, -radius),
          rotation: Vector3(0, 180, 0),
          width: size,
          height: size,
          widget: faces[2].widget,
          children: faces[2].children),
      Actor(
          name: faces[3].name,
          position: Vector3(-radius, 0, 0),
          rotation: Vector3(0, 270, 0),
          width: size,
          height: size,
          widget: faces[3].widget,
          children: faces[3].children),
      Actor(
          name: faces[4].name,
          position: Vector3(0, -radius, 0),
          rotation: Vector3(90, 0, 0),
          width: size,
          height: size,
          widget: faces[4].widget,
          children: faces[4].children),
      Actor(
          name: faces[5].name,
          position: Vector3(0, radius, 0),
          rotation: Vector3(270, 0, 0),
          width: size,
          height: size,
          widget: faces[5].widget,
          children: faces[5].children),
    ]);
  }

  Widget makeBlockFace(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(
            color: Color.fromRGBO(77, 77, 77, 1.0), width: size * 0.005),
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(25, 25, 25, 1.0),
            Color.fromRGBO(56, 56, 56, 1.0),
            Color.fromRGBO(25, 25, 25, 1.0)
          ],
          stops: [0.1, 0.5, 0.9],
          begin: FractionalOffset.topRight,
          end: FractionalOffset.bottomLeft,
          tileMode: TileMode.repeated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double blockSize = 600;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Stage(
        onSceneCreated: _onSceneCreated,
        children: [
          makeBlock(
            name: 'block',
            position: Vector3(0, 0, 0),
            size: blockSize * 1.1,
            faces: [
              Actor(
                name: 'front',
                widget: makeBlockFace(blockSize),
                children: [
                  Actor(
                    position: Vector3(0, 0, blockSize * 0.06),
                    width: blockSize,
                    height: blockSize,
                    widget: Container(
                        key: ValueKey('hour'),
                        child: FlareActor('assets/clock/hour.flr',
                            animation: 'idle', controller: _clockControl)),
                  ),
                  Actor(
                    position: Vector3(0, 0, 0),
                    width: blockSize,
                    height: blockSize,
                    widget: Container(
                        key: ValueKey('minute'),
                        child: FlareActor('assets/clock/minute.flr')),
                  ),
                  Actor(
                    position: Vector3(0, 0, blockSize * 0.068),
                    width: blockSize,
                    height: blockSize,
                    widget: Container(
                        key: ValueKey('hour_hand'),
                        child: FlareActor('assets/clock/hand.flr',
                            controller: _clockHandControl)),
                  ),
                ],
              ),
              Actor(
                name: 'right',
                widget: makeBlockFace(blockSize),
                children: [
                  Actor(
                    position: Vector3(0, 0, 0),
                    width: blockSize,
                    height: blockSize * 0.85,
                    widget: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            DateFormat('MMMM').format(DateTime.now()),
                            style: TextStyle(
                                fontSize: blockSize * 0.15,
                                color: Colors.white.withOpacity(0.5)),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            DateFormat('EEEE').format(DateTime.now()),
                            style: TextStyle(
                                fontSize: blockSize * 0.13,
                                color: Colors.white.withOpacity(0.5)),
                          ),
                        )
                      ],
                    ),
                  ),
                  Actor(
                    position: Vector3(0, 0, blockSize * 0.02),
                    width: blockSize,
                    height: blockSize,
                    widget: Center(
                      child: Text(
                        DateFormat('d').format(DateTime.now()),
                        style: TextStyle(
                            fontSize: blockSize * 0.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.6)),
                      ),
                    ),
                  ),
                  Actor(
                    position: Vector3(0, 0, 0),
                    width: blockSize,
                    height: blockSize,
                    widget: Center(
                      child: Text(
                        DateFormat('d').format(DateTime.now()),
                        style: TextStyle(
                            fontSize: blockSize * 0.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.3)),
                      ),
                    ),
                  ),
                ],
              ),
              Actor(
                name: 'back',
                widget: makeBlockFace(blockSize),
                children: [
                  Actor(
                    position: Vector3(0, 0, 0),
                    width: blockSize * 0.8,
                    height: blockSize * 0.8,
                    widget: Column(
                      children: <Widget>[
                        _textField(_location, 'Location', (String location) {
                          setState(() {
                            _location = location;
                          });
                        }),
                        _textField(
                            _convertFromCelsius(_temperature)
                                .toStringAsFixed(0),
                            'Temperature', (String temperature) {
                          setState(() {
                            _temperature =
                                _convertToCelsius(double.parse(temperature));
                          });
                        }),
                        _enumMenu('Weather', _weatherCondition,
                            WeatherCondition.values,
                            (WeatherCondition? condition) {
                          setState(() {
                            _weatherCondition = condition!;
                          });
                        }),
                        _enumMenu('Units', _unit, TemperatureUnit.values,
                            (TemperatureUnit? unit) {
                          setState(() {
                            _unit = unit!;
                          });
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              Actor(
                name: 'left',
                widget: makeBlockFace(blockSize),
                children: [
                  Actor(
                    position: Vector3(0, 0, 0),
                    width: blockSize,
                    height: blockSize * 0.85,
                    widget: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topCenter,
                          child: FittedBox(
                              child: Text(_location,
                                  style: TextStyle(
                                      fontSize: blockSize * 0.09,
                                      color: Colors.white.withOpacity(0.35)))),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(enumToString(_weatherCondition),
                              style: TextStyle(
                                  fontSize: blockSize * 0.13,
                                  color: Colors.white.withOpacity(0.6))),
                        ),
                      ],
                    ),
                  ),
                  Actor(
                    position: Vector3(0, 0, blockSize * 0.02),
                    width: blockSize,
                    height: blockSize,
                    widget: Center(
                      child: Text(
                        _convertFromCelsius(_temperature).toStringAsFixed(0) +
                            unitString,
                        style: TextStyle(
                            fontSize: blockSize / 3,
                            color: Colors.white.withOpacity(0.6)),
                      ),
                    ),
                  ),
                  Actor(
                    position: Vector3(0, 0, 0),
                    width: blockSize,
                    height: blockSize,
                    widget: Center(
                      child: Text(
                        _convertFromCelsius(_temperature).toStringAsFixed(0) +
                            unitString,
                        style: TextStyle(
                            fontSize: blockSize / 3,
                            color: Colors.black.withOpacity(0.3)),
                      ),
                    ),
                  ),
                ],
              ),
              Actor(name: 'top', widget: makeBlockFace(blockSize)),
              Actor(name: 'bottom', widget: makeBlockFace(blockSize)),
            ],
          ),
        ],
      ),
    );
  }
}

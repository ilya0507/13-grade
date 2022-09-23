// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class PlatformChannel extends StatefulWidget {
  const PlatformChannel({Key? key}) : super(key: key);

  @override
  State<PlatformChannel> createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<PlatformChannel> {
  String _batteryLevel = 'Уровень заряда батареи: неизвестно.';
  String _examResult = 'Результаты сдачи экзамена: неизвестно.';

  // Метод для проверки заряда батареи
  static const MethodChannel methodChannel =
  MethodChannel('batteryChargeLevel');
  // Метод для вызова нативного Toast
  static const MethodChannel platformMethodChannel =
  MethodChannel('nativeChannel');
  // Метод для вызова нативного диалога и получения данных во Flutter
  static const MethodChannel platformDialog =
  MethodChannel('dialogChannel');


  // Проверка заряда батареи
  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int? result = await methodChannel.invokeMethod('getBatteryLevel');
      batteryLevel = 'Уровень заряда батареи: $result%.';
    } on PlatformException catch (e) {
      if (e.code == 'NO_BATTERY') {
        batteryLevel = 'No battery.';
      } else {
        batteryLevel = 'Failed to get battery level.';
      }
    }
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  // Вызов нативного Toast
  Future<void> callNativeToast() async {
    try {
      await platformMethodChannel.invokeMethod(
        'setToast', {
        'myText':'Этот текст будет показан в Toast через нативный канал. Привет, Андрей)'
      },);
    } on PlatformException catch (e) {
      debugPrint('Не срослось по причине ошибки: $e');
    }
  }

  // Вызов нативного Dialog с передачей данных в натив
  // и получением данных из натива + Toast
  Future<void> callNativeDialog() async {
    String examResult;
    try {
      final String? result = await platformDialog.invokeMethod('dialogChannel');
      examResult = 'Результаты сдачи экзамена: \n$result.';
    } on PlatformException catch (e) {
      examResult = 'Не срослось по причине ошибки: $e';
    }
    setState(() {
      _examResult = examResult;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _batteryLevel,
                key: const Key('Battery level label'),
                style: const TextStyle(fontSize: 16),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _getBatteryLevel,
                  child: const Text(
                    'Обновить данные заряда',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: callNativeToast,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Вызов Toast \nиз нативного кода',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _examResult,
                  key: Key('Exam result $_examResult'),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: callNativeDialog,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const <Widget>[
                        Icon(
                          Icons.touch_app,
                          color: Colors.white,
                          size: 32.0,
                        ),
                        SizedBox(
                          width:10,
                        ),
                        Text(
                          'Вызов Dialog \nиз нативного кода',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: PlatformChannel()));
}
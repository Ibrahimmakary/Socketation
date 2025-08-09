import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/websocket_testing_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Socketation - WebSocket Tester',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WebsocketTestingView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

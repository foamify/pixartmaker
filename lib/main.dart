import 'package:flutter/material.dart';
import 'package:pixartmaker/modules/main/view/canvas_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CanvasView(size: MediaQuery.of(context).size),
        ),
      ),
    );
  }
}

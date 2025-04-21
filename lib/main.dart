import 'package:flutter/material.dart';
import 'routes/app.dart';

void main() async {
  await App.initialize();
  runApp(const App());
}

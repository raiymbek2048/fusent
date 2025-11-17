import 'package:flutter/material.dart';
import 'package:fusent_mobile/app.dart';
import 'package:fusent_mobile/core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(const FucentApp());
}

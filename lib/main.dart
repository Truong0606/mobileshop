import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_shopping_chatbot/app.dart';
import 'package:smart_shopping_chatbot/core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  // Initialise app config from .env values
  AppConfig.init();

  // ignore: avoid_print
  print('🚀 ${AppConfig.instance}');

  runApp(const ProviderScope(child: App()));
}

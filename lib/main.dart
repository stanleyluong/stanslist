import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For debugging: print environment variables
  const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  print(
      "Environment check - API Key: ${apiKey.isNotEmpty ? 'Set' : 'Missing'}, Project ID: $projectId");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: StansListApp(),
    ),
  );
}

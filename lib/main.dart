import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'services/directus_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';

Future main() async {
  try {
    await dotenv.load(fileName: "lib/assets/.env");
    developer.log('Environment loaded successfully', name: 'Startup');
    runApp(MyApp());
  } catch (e) {
    developer.log('Failed to load environment', name: 'Startup', error: e);
    runApp(ErrorApp(error: e));
  }
}

class ErrorApp extends StatelessWidget {
  final dynamic error;
  
  const ErrorApp({super.key, this.error});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Startup Error: $error'),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final DirectusService _directusService = DirectusService();
  
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _directusService.getGlobalMetadata(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          developer.log('App initialization error: ${snapshot.error}', name: 'MyApp');
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load application'),
                    Text('Error: ${snapshot.error}'),
                  ],
                ),
              ),
            ),
          );
        } else {
          final metadata = snapshot.data!;
          return MaterialApp(
            title: metadata['title'] ?? 'My App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const HomeScreen(),
          );
        }
      },
    );
  }
}
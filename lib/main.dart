import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ui/screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
    runApp(const MyApp());
  } catch (e) {
    print('Error during app initialization: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthManager()),
        ChangeNotifierProvider(create: (context) => BookService()),
        ChangeNotifierProvider(create: (context) => BookManager()),
      ],
      child: MaterialApp(
        title: 'Book Reading App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepPurple,
            accentColor: Colors.indigo,
          ),
          fontFamily: 'Roboto',
        ),
        initialRoute: AuthScreen.routeName, // Start with Auth Screen
        routes: {
          AuthScreen.routeName: (ctx) => const AuthScreen(),
          BookOverviewScreen.routeName: (ctx) => const BookOverviewScreen(),
        },
      ),
    );
  }
}

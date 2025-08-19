import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dating_app/screens/login_screen.dart';
import 'package:flutter_dating_app/screens/register_screen.dart';
import 'package:flutter_dating_app/screens/main_screen.dart';
import 'package:flutter_dating_app/services/auth_service.dart';
import 'package:flutter_dating_app/services/image_service.dart';
import 'package:flutter_dating_app/services/event_service.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final authService = AuthService();
  await authService.initDatabase();

  // Create services
  final eventService = EventService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        Provider(create: (_) => eventService),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dating App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF1E88E5), // Changed from pink to blue
        colorScheme: ColorScheme.light(
          primary: Color(0xFF1E88E5), // Changed from pink to blue
          secondary: Color(0xFF0D47A1), // Darker blue
          tertiary: Color(0xFF42A5F5), // Lighter blue
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color(0xFF1E88E5), // Changed from pink to blue
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Color(0xFF1E88E5)), // Changed from pink to blue
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        cardTheme: CardTheme(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: Consumer<AuthService>(
        builder: (context, authService, _) {
          return FutureBuilder<bool>(
            future: authService.isLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final bool isLoggedIn = snapshot.data ?? false;
              return isLoggedIn ? MainScreen() : LoginScreen();
            },
          );
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/main': (context) => MainScreen(),
      },
    );
  }
}

class LostDataWidget extends StatefulWidget {
  final Widget child;

  const LostDataWidget({Key? key, required this.child}) : super(key: key);

  @override
  _LostDataWidgetState createState() => _LostDataWidgetState();
}

class _LostDataWidgetState extends State<LostDataWidget> {
  @override
  void initState() {
    super.initState();
    _checkForLostData();
  }

  Future<void> _checkForLostData() async {
    final lostFiles = await ImageService.retrieveLostData(context);
    if (lostFiles != null && lostFiles.isNotEmpty) {
      // Handle lost files - in a real app, you might want to show them to the user
      // or save them automatically
      print('Found ${lostFiles.length} lost files');

      // Example of saving the first lost file
      if (lostFiles.isNotEmpty) {
        final savedPath = await ImageService.saveImagePermanently(lostFiles.first);
        print('Saved lost file to: $savedPath');

        // You might want to update your UI or notify the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recovered images from previous session'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                // Navigate to gallery or show the images
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

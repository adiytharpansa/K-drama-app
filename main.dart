import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/genre_screen.dart';
import 'screens/favorite_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'services/drama_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => DramaService(),
      child: MaterialApp(
        title: 'K-drama',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Color(0xFF121212),
          cardColor: Color(0xFF1E1E1E),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
            centerTitle: true,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1E1E1E),
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
            titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        home: SplashScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    HomeScreen(),
    GenreScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Genre',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

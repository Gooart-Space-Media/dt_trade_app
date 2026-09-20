const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// 1. Light Theme Fix
const oldLightTheme = `      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFFF59E0B), // 金色主调
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.5,
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),`;

const newLightTheme = `      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFFF59E0B), // 金色主调
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardColor: Colors.white,
        cardTheme: const CardTheme(color: Colors.white, surfaceTintColor: Colors.transparent),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0xFFFEF3C7),
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0.5,
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),`;

code = code.replace(oldLightTheme, newLightTheme);

// 2. Dark Theme Fix
const oldDarkTheme = `      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFFF59E0B), // 金色主调
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          elevation: 0.5,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),`;

const newDarkTheme = `      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFFF59E0B), // 金色主调
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        cardTheme: const CardTheme(color: Color(0xFF1E293B), surfaceTintColor: Colors.transparent),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFF1E293B),
          indicatorColor: Color(0xFF452E03),
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          surfaceTintColor: Colors.transparent,
          elevation: 0.5,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),`;

code = code.replace(oldDarkTheme, newDarkTheme);

// 3. Logo Badge Fix
const oldBadge = `            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]), // 流金渐变
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('DT', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
            ),`;

const newBadge = `            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset('assets/logo.png', width: 26, height: 26, fit: BoxFit.cover),
            ),`;

code = code.replace(oldBadge, newBadge);

fs.writeFileSync('lib/main.dart', code);
console.log('UI updated successfully!');

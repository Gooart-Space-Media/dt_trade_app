import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  String content = file.readAsStringSync();

  // 1. Monte Carlo Banner (Rose -> Amber)
  content = content.replaceAll(
    'color: const Color(0xFFE11D48),',
    'color: const Color(0xFFF59E0B), // 统一品牌金色',
  );

  // 2. Info Blue Banner (Colors.blueAccent -> Slate)
  content = content.replaceAll(
    'color: Colors.blueAccent, size: 20)',
    'color: const Color(0xFF64748B), size: 20)',
  );
  content = content.replaceAll(
    'color: Colors.blueAccent.withOpacity(0.08),',
    'color: const Color(0xFF64748B).withOpacity(0.08),',
  );
  content = content.replaceAll(
    'color: Colors.blueAccent, size: 16),',
    'color: const Color(0xFF64748B), size: 16),',
  );
  content = content.replaceAll(
    'color: Colors.blueAccent,\n                            fontWeight: FontWeight.w600),',
    'color: const Color(0xFF64748B),\n                            fontWeight: FontWeight.w600),',
  );
  // Wait, the regex replace for the multiline one might be tricky. Let's just do it directly.
  content = content.replaceAll(
    'color: Colors.blueAccent,',
    'color: const Color(0xFF64748B),',
  );
  
  // 3. Traditional Single Track (Purple -> Slate)
  content = content.replaceAll(
    'const Color(0xFF8B5CF6)',
    'const Color(0xFF64748B)',
  );

  // 4. Tip Box (Indigo -> Amber Theme)
  content = content.replaceAll(
    'color: const Color(0xFFEEF2FF),',
    'color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),',
  );
  content = content.replaceAll(
    'border: Border.all(color: const Color(0xFFC7D2FE)),',
    'border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFFDE68A)),',
  );
  content = content.replaceAll(
    'color: Color(0xFF312E81))),',
    'color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309))),',
  );
  content = content.replaceAll(
    'color: Color(0xFF312E81),',
    'color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),',
  );

  file.writeAsStringSync(content);
  print('Color themes unified!');
}

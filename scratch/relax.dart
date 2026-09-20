import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  String code = file.readAsStringSync();
  // Normalize line endings for replacement
  code = code.replaceAll('\r\n', '\n');

  // 1. Add back chip vertical padding (5 -> 7)
  code = code.replaceAll(
    'padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),\n        decoration: BoxDecoration(\n          color: isSelected',
    'padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),\n        decoration: BoxDecoration(\n          color: isSelected'
  );

  // 2. Add back space after Mode Switch (8 -> 10)
  code = code.replaceAll(
    '),\n        const SizedBox(height: 8),\n        // Timeframe',
    '),\n        const SizedBox(height: 10),\n        // Timeframe'
  );
  
  // 3. Add back runSpacing in Toolbar (6 -> 10)
  code = code.replaceAll(
    'Wrap(\n          spacing: 12,\n          runSpacing: 6,',
    'Wrap(\n          spacing: 12,\n          runSpacing: 10,'
  );
  
  // 4. Add back space after Toolbar (6 -> 8)
  code = code.replaceAll(
    '),\n\n        const SizedBox(height: 6),\n        // 当前选中品种高阶信息标牌',
    '),\n\n        const SizedBox(height: 8),\n        // 当前选中品种高阶信息标牌'
  );
  
  // 5. Add back vertical padding in Current Pair Info (6 -> 8)
  code = code.replaceAll(
    '// 当前选中品种高阶信息标牌\n        Container(\n          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),',
    '// 当前选中品种高阶信息标牌\n        Container(\n          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),'
  );
  
  // 6. Add back space after Current Pair Info (6 -> 8)
  code = code.replaceAll(
    '),\n\n        const SizedBox(height: 6),\n        // 品种分类过滤 Tabs',
    '),\n\n        const SizedBox(height: 8),\n        // 品种分类过滤 Tabs'
  );
  
  // 7. Add back space after Pair Tabs (8 -> 10)
  code = code.replaceAll(
    '),\n\n        const SizedBox(height: 8),\n        Row(\n          crossAxisAlignment: CrossAxisAlignment.start,',
    '),\n\n        const SizedBox(height: 10),\n        Row(\n          crossAxisAlignment: CrossAxisAlignment.start,'
  );

  file.writeAsStringSync(code);
  print('Done relaxing spacing in Dart!');
}

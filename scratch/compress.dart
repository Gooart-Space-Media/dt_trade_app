import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  String code = file.readAsStringSync();
  // Normalize line endings for replacement
  code = code.replaceAll('\r\n', '\n');

  code = code.replaceAll('padding: const EdgeInsets.all(4),\n          decoration: BoxDecoration(\n            color: Theme.of(context).cardColor', 'padding: const EdgeInsets.all(2),\n          decoration: BoxDecoration(\n            color: Theme.of(context).cardColor');
  
  code = code.replaceAll('padding: const EdgeInsets.symmetric(vertical: 8),\n                    decoration: BoxDecoration(', 'padding: const EdgeInsets.symmetric(vertical: 6),\n                    decoration: BoxDecoration(');
  
  code = code.replaceAll('),\n        const SizedBox(height: 12),\n        // Timeframe', '),\n        const SizedBox(height: 8),\n        // Timeframe');
  
  code = code.replaceAll('Wrap(\n          spacing: 12,\n          runSpacing: 12,', 'Wrap(\n          spacing: 12,\n          runSpacing: 6,');
  
  code = code.replaceAll('),\n\n        const SizedBox(height: 10),\n        // 当前选中品种高阶信息标牌', '),\n\n        const SizedBox(height: 6),\n        // 当前选中品种高阶信息标牌');
  
  code = code.replaceAll('// 当前选中品种高阶信息标牌\n        Container(\n          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),', '// 当前选中品种高阶信息标牌\n        Container(\n          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),');
  
  code = code.replaceAll('),\n\n        const SizedBox(height: 12),\n        // 品种分类过滤 Tabs', '),\n\n        const SizedBox(height: 6),\n        // 品种分类过滤 Tabs');
  
  code = code.replaceAll('),\n\n        const SizedBox(height: 12),\n        Row(\n          crossAxisAlignment: CrossAxisAlignment.start,', '),\n\n        const SizedBox(height: 8),\n        Row(\n          crossAxisAlignment: CrossAxisAlignment.start,');

  file.writeAsStringSync(code);
  print('Done in Dart!');
}

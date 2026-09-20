const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// Replace Colors.green.shade50 with dynamic color
code = code.replace(/Colors\.green\.shade50/g, 'Theme.of(context).brightness == Brightness.dark ? const Color(0xFF022C22) : const Color(0xFFF0FDF4)');

// Replace Colors.green.shade900 with dynamic color
code = code.replace(/Colors\.green\.shade900/g, 'Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6EE7B7) : const Color(0xFF14532D)');

fs.writeFileSync('lib/main.dart', code);
console.log('Fixed colors');

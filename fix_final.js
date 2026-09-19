const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// The broken string part is exactly: · 初始本金 \{startBal.toStringAsFixed(0)}
code = code.replace(
  /· 初始本金 \\\{startBal\.toStringAsFixed\(0\)\}/g,
  '· 初始本金 \\$${startBal.toStringAsFixed(0)}'
);

code = code.replace(
  /Expanded\(\s*flex: 45,/g,
  'Expanded(\n                      flex: 48,'
);
code = code.replace(
  /Expanded\(\s*flex: 55,/g,
  'Expanded(\n                      flex: 52,'
);

fs.writeFileSync('lib/main.dart', code);
console.log('Done');

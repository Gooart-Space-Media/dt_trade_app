const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

code = code.replace(
  /· 初始本金 \\\$\{startBal\.toStringAsFixed\(0\)\}/g,
  () => '· 初始本金 \\$${startBal.toStringAsFixed(0)}'
);

fs.writeFileSync('lib/main.dart', code);
console.log('Done');

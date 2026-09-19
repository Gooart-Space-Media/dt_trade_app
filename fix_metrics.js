const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

code = code.replace(/_row\('最大回撤', '%', ddColor\),/g, "_row('最大回撤', '\\$${drawdown.toStringAsFixed(1)}%', ddColor),");
code = code.replace(/_row\('破产熔断率', '%', brColor\),/g, "_row('破产熔断率', '\\$${blowRate.toStringAsFixed(1)}%', brColor),");
code = code.replace(/_row\('最大连亏', ' 次', Colors.grey\),/g, "_row('最大连亏', '\\$${maxStreak} 次', Colors.grey),");

fs.writeFileSync('lib/main.dart', code);
console.log('Fixed missing metrics!');

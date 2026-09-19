const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');
code = code.replace("import 'package:fl_chart/fl_chart.dart';\n", "");
code = code.replace("import 'package:fl_chart/fl_chart.dart';\r\n", "");
fs.writeFileSync('lib/main.dart', code);
console.log('Removed fl_chart import!');

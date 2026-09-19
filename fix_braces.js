const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// Replace all \{ with \$${
code = code.split('\\{').join('\\$${');

// Fix the missing riskPct values
code = code.replace(/2x% = %/g, '2x${(riskPct/2).toStringAsFixed(1)}% = ${riskPct.toStringAsFixed(0)}%');
code = code.replace(/1x%/g, '1x${riskPct.toStringAsFixed(0)}%');
code = code.replace(/% \(\\\$\$\{riskAmount/g, '${riskPct.toStringAsFixed(0)}% (\\$${riskAmount');
code = code.replace(/2x% \(/g, '2x${(riskPct/2).toStringAsFixed(1)}% (');
code = code.replace(/\(%\)/g, '(${riskPct.toStringAsFixed(0)}%)');

// Fix the ≈ RM issue
code = code.replace(/'≈ RM ',/g, "'≈ RM ${(finalBal * 4.5).toStringAsFixed(0)}',");

fs.writeFileSync('lib/main.dart', code);
console.log('Fixed braces and percentages!');

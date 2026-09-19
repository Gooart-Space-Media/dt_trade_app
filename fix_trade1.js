const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// Replace * 1.0 with * rr in both Monte Carlo and Actual runs
code = code.replace(/balDt \+= \(riskDt \/ 2\.0 \* 1\.0\) \+ \(riskDt \/ 2\.0 \* runnerRR\);/g, 'balDt += (riskDt / 2.0 * rr) + (riskDt / 2.0 * runnerRR);');
code = code.replace(/dtBalance \+= \(riskDt \/ 2\.0 \* 1\.0\) \+ \(riskDt \/ 2\.0 \* runnerRR\);/g, 'dtBalance += (riskDt / 2.0 * rr) + (riskDt / 2.0 * runnerRR);');

// Update the UI text
code = code.replace('通过 1:1 提前落袋保本', '通过 Trade 1 提前落袋保本');

fs.writeFileSync('lib/main.dart', code);
console.log('Trade 1 RR updated!');

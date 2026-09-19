const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// 1. Fix dropdown overflow
code = code.replace(/DropdownButtonFormField<double>\(/g, 'DropdownButtonFormField<double>(\n                isExpanded: true,');

// 3. Shrink the bottom part of the result card!
// Find _buildResultCard definition and usages
code = code.replace(/padding: const EdgeInsets\.all\(16\)/g, 'padding: const EdgeInsets.all(10)'); // Shrink cards padding globally

// Shrink the font size in result card
code = code.replace(/fontSize: 32/g, 'fontSize: 24'); // Shrink large balance text
code = code.replace(/fontSize: 14/g, 'fontSize: 12'); 

// 4. In _buildBanner, hide the desc
code = code.replace(/if \(desc\.isNotEmpty\) \.\.\.\[[\s\S]*?\]/, '');

// Make sure the input labels don't overflow
code = code.replace(/labelText: '本金 \(USD\)'/g, "labelText: '本金'");
code = code.replace(/labelText: '胜率 \(\\\${riskPct.toStringAsFixed\(0\)}%\)'/g, "labelText: '胜率(%)'");
code = code.replace(/labelText: '单笔风险 \(\\\${riskPct.toStringAsFixed\(0\)}%\)'/g, "labelText: '风险(%)'");
code = code.replace(/labelText: '盈亏比 \(RR\)'/g, "labelText: '盈亏比'");

fs.writeFileSync('lib/main.dart', code);
console.log('Processed');

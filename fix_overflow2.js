const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// 1. Fix dropdown items text
code = code.replace(/Text\('1:1 \(保守\)'\)/g, "Text('1:1')");
code = code.replace(/Text\('1:1.5 \(稳健\)'\)/g, "Text('1:1.5')");
code = code.replace(/Text\('1:2 \(标准\)'\)/g, "Text('1:2')");
code = code.replace(/Text\('1:3 \(极佳\)'\)/g, "Text('1:3')");

// 2. Fix labels in inputs
code = code.replace(/labelText: '本金 \(USD\)'/g, "labelText: '本金'");
code = code.replace(/labelText: '胜率 \(\\\$\\{riskPct\.toStringAsFixed\(0\)\\}%\)'/g, "labelText: '胜率(%)'");
code = code.replace(/labelText: '单笔风险 \(\\\$\\{riskPct\.toStringAsFixed\(0\)\\}%\)'/g, "labelText: '风险(%)'");
code = code.replace(/labelText: '胜率 \(%\)'/g, "labelText: '胜率(%)'");
code = code.replace(/labelText: '单笔风险 \(%\)'/g, "labelText: '风险(%)'");
code = code.replace(/labelText: '盈亏比 \(RR\)'/g, "labelText: '盈亏比'");

// 3. Remove desc in banner
code = code.replace(/desc: '用客观概率打破赌徒侥幸心理。模拟连续12个月后资金曲线，直观感受风控红线的威力和回撤规律。',/g, "desc: '',");
code = code.replace(/if \(desc\.isNotEmpty\) \.\.\.\[[\s\S]*?\]/g, "");
// Remove the desc parameter usage in _buildBanner
code = code.replace(/Widget _buildBanner\(\{[\s\S]*?\}\) \{[\s\S]*?return Container\(/g, match => {
  return match.replace(/if \(desc\.isNotEmpty\)[\s\S]*?Text\(desc[\s\S]*?\),/, '');
});

// 4. Shrink ResultCard
code = code.replace(/Widget _buildResultCard\(\{[\s\S]*?\}\) \{[\s\S]*?return Container\(/g, match => {
  return match; // No changes to signature
});
code = code.replace(/padding: const EdgeInsets\.all\(12\),\s*decoration: BoxDecoration\(/, "padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),\n      decoration: BoxDecoration(");

code = code.replace(/const SizedBox\(height: 8\),\s*Text\('\\\$\\\$\{finalBal\.toStringAsFixed\(0\)\\}', style: TextStyle\(fontSize: 24/, "const SizedBox(height: 2),\n          Text('\\\$${finalBal.toStringAsFixed(0)}', style: TextStyle(fontSize: 20");

code = code.replace(/const Padding\(padding: EdgeInsets\.symmetric\(vertical: 8\), child: Divider\(height: 1, thickness: 1\)\),/g, "const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Divider(height: 1, thickness: 1)),");

// Change padding in leftContent box
code = code.replace(/padding: const EdgeInsets\.all\(8\),\s*child: Row\(\s*crossAxisAlignment: CrossAxisAlignment\.start,\s*children: \[\s*Expanded\(\s*child: _buildResultCard/, "padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),\n                      child: Row(\n                        crossAxisAlignment: CrossAxisAlignment.start,\n                        children: [\n                          Expanded(\n                            child: _buildResultCard");

fs.writeFileSync('lib/main.dart', code);
console.log('Fixed again');

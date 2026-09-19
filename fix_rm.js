const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// 1. Fix the string interpolation bug in the blue banner
const oldBannerText = "· 初始本金 \\$ {startBal.toStringAsFixed(0)} (≈ RM ${(startBal * 4.5).toStringAsFixed(0)})',";
const newBannerText = "· 初始本金 \\$${startBal.toStringAsFixed(0)} (≈ RM ${(startBal * 4.5).toStringAsFixed(0)})',";

// In my last script, I accidentally escaped the $ before the {
// Let's use a regex to fix any broken interpolation
code = code.replace(
  /· 初始本金 \\\$ \{startBal\.toStringAsFixed\(0\)\} \(/g,
  '· 初始本金 \\$${startBal.toStringAsFixed(0)} ('
);

// 2. Monthly grid: side-by-side instead of stacked
const oldGrid = `                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(textStr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: textColor)),
                                    if (rmStr.isNotEmpty)
                                      Text(rmStr, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.6))),
                                  ],
                                ),`;

const newGrid = `                                Row(
                                  children: [
                                    Text(textStr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: textColor)),
                                    if (rmStr.isNotEmpty) ...[
                                      const SizedBox(width: 4),
                                      Text(rmStr, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.6))),
                                    ]
                                  ],
                                ),`;

code = code.replace(oldGrid, newGrid);

fs.writeFileSync('lib/main.dart', code);
console.log('Done');

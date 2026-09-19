const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// 1. Update Subheader blue banner
const oldBannerText = "· 初始本金 \\$${startBal.toStringAsFixed(0)}',";
const newBannerText = "· 初始本金 \\$${startBal.toStringAsFixed(0)} (≈ RM ${(startBal * 4.5).toStringAsFixed(0)})',";
code = code.replace(oldBannerText, newBannerText);

// 2. Update Grid Item
const oldGrid = `                        return Container(
                          width: (gridConstraints.maxWidth - 24) / 4,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: borderColor)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('月', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
                                Text(textStr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: textColor)),
                              ],
                            ),
                          ),
                        );`;

const newGrid = `                        String rmStr = '';
                        if (val != 0) {
                          double rmVal = val.abs() * 4.5;
                          rmStr = '≈ RM \${rmVal.toStringAsFixed(0)}';
                        }
                        
                        return Container(
                          width: (gridConstraints.maxWidth - 24) / 4,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: borderColor)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('月', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(textStr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: textColor)),
                                    if (rmStr.isNotEmpty)
                                      Text(rmStr, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.6))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );`;

code = code.replace(oldGrid, newGrid);

fs.writeFileSync('lib/main.dart', code);
console.log('Done');

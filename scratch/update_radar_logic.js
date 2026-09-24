const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf8');

// Replace signature
code = code.replace("Map<String, dynamic> _getSessionInfo() {", "Map<String, dynamic> _getSessionInfo(BuildContext context) {");
// Replace calls
code = code.replace(/_getSessionInfo\(\)/g, "_getSessionInfo(context)");

// Now replace the contents of _getSessionInfo
// 1
code = code.replace("status = '🌅 晨间设单窗口';", "status = AppLocalizations.of(context)!.radarStatus1;");
code = code.replace("desc = 'D1 日线收盘，7:00-8:00 挂单后关闭软件 (Set & Forget)';", "desc = AppLocalizations.of(context)!.radarDesc1;");
code = code.replace("countdown = '距窗口关闭 ${diff}分';", "countdown = AppLocalizations.of(context)!.radarCount1(diff.toString());");

// 2
code = code.replace("status = '☕ 亚盘静默观察期';", "status = AppLocalizations.of(context)!.radarStatus2;");
code = code.replace("desc = '让市场来找我。亚盘波动小，绝不因 FOMO 手动追单';", "desc = AppLocalizations.of(context)!.radarDesc2;");
code = code.replace("countdown = '距 15:00 伦敦盘 ${dh}h${dm.toString().padLeft(2, '0')}m';", "countdown = AppLocalizations.of(context)!.radarCount2(dh.toString(), dm.toString().padStart(2, '0'));");

// 3
code = code.replace("status = '🇬🇧 伦敦盘爆发中';", "status = AppLocalizations.of(context)!.radarStatus3;");
code = code.replace("desc = '欧洲资金进场，日线挂单迎来首波突破与测试';", "desc = AppLocalizations.of(context)!.radarDesc3;");
code = code.replace("countdown = '距 20:30 主战场 ${dh}h${dm.toString().padLeft(2, '0')}m';", "countdown = AppLocalizations.of(context)!.radarCount3(dh.toString(), dm.toString().padStart(2, '0'));");

// 4
code = code.replace("status = '🔥 伦纽重叠主战场';", "status = AppLocalizations.of(context)!.radarStatus4;");
code = code.replace("desc = '全天最大波动窗口！20:30-24:00 留意 Trade 1 止盈与推保本';", "desc = AppLocalizations.of(context)!.radarDesc4;");
code = code.replace("countdown = '距重叠期结束 ${dh}h${dm.toString().padLeft(2, '0')}m';", "countdown = AppLocalizations.of(context)!.radarCount4(dh.toString(), dm.toString().padStart(2, '0'));");

// 5
code = code.replace("status = '🌙 纽约尾盘与休市';", "status = AppLocalizations.of(context)!.radarStatus5;");
code = code.replace("desc = '市场趋缓，保持良好作息，迎接明日晨间开盘';", "desc = AppLocalizations.of(context)!.radarDesc5;");
code = code.replace("countdown = '距明日 07:00 晨盘 ${dh}h${dm.toString().padLeft(2, '0')}m';", "countdown = AppLocalizations.of(context)!.radarCount5(dh.toString(), dm.toString().padStart(2, '0'));");


// Also increase the font of the top clock
code = code.replace(/Text\(\n\s*sessionInfo\['status'\],[\s\S]*?style:\s*TextStyle\(/g, "Text(\n                    sessionInfo['status'],\n                    style: TextStyle(\n                      fontSize: 12.5,\n                      fontWeight: FontWeight.bold,\n");
code = code.replace(/Text\(\n\s*sessionInfo\['countdown'\],[\s\S]*?style:\s*TextStyle\(/g, "Text(\n                      sessionInfo['countdown'],\n                      style: TextStyle(\n                        fontSize: 11,\n                        fontWeight: FontWeight.bold,\n");
code = code.replace(/Text\(\n\s*sessionInfo\['desc'\],[\s\S]*?style:\s*TextStyle\(/g, "Text(\n                        sessionInfo['desc'],\n                        style: TextStyle(\n                          fontSize: 12,\n");

fs.writeFileSync('lib/main.dart', code);
console.log("Replaced radar text");

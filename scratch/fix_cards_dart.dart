import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  String content = file.readAsStringSync();

  String oldCode = '''
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildResultCard(
                        title:
                            'DT 双轨 (2x\${(riskPct / 2).toStringAsFixed(1)}% = \${riskPct.toStringAsFixed(0)}%)',
                        subtitle:
                            '风控: \\\$\${riskAmount.toStringAsFixed(0)} (A:\\\$\${(riskAmount / 2).toStringAsFixed(0)}+B:\\\$\${(riskAmount / 2).toStringAsFixed(0)})',
                        finalBal: simResult!['dtFinal'],
                        maxRisk:
                            '\\\$\${riskAmount.toStringAsFixed(0)} (\${riskPct.toStringAsFixed(0)}%)',
                        drawdown: simResult!['dtDrawdown'],
                        blowRate: simResult!['dtBlowRate'],
                        maxStreak: simResult!['dtMaxStreak'],
                        color: const Color(0xFF10B981),
                        isBlownUp: simResult!['dtBlownUp'],
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildResultCard(
                        title: '传统单轨 (1x\${riskPct.toStringAsFixed(0)}%)',
                        subtitle:
                            '单笔死扛风控: \\\$\${riskAmount.toStringAsFixed(0)} (无保本)',
                        finalBal: simResult!['stFinal'],
                        maxRisk:
                            '\\\$\${riskAmount.toStringAsFixed(0)} (\${riskPct.toStringAsFixed(0)}%)',
                        drawdown: simResult!['stDrawdown'],
                        blowRate: simResult!['stBlowRate'],
                        maxStreak: simResult!['stMaxStreak'],
                        color: const Color(0xFF8B5CF6),
                        isBlownUp: simResult!['stBlownUp'],
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),''';

  String newCode = '''
                child: isDesktop ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildResultCard(
                        title:
                            'DT 双轨 (2x\${(riskPct / 2).toStringAsFixed(1)}% = \${riskPct.toStringAsFixed(0)}%)',
                        subtitle:
                            '风控: \\\$\${riskAmount.toStringAsFixed(0)} (A:\\\$\${(riskAmount / 2).toStringAsFixed(0)}+B:\\\$\${(riskAmount / 2).toStringAsFixed(0)})',
                        finalBal: simResult!['dtFinal'],
                        maxRisk:
                            '\\\$\${riskAmount.toStringAsFixed(0)} (\${riskPct.toStringAsFixed(0)}%)',
                        drawdown: simResult!['dtDrawdown'],
                        blowRate: simResult!['dtBlowRate'],
                        maxStreak: simResult!['dtMaxStreak'],
                        color: const Color(0xFF10B981),
                        isBlownUp: simResult!['dtBlownUp'],
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildResultCard(
                        title: '传统单轨 (1x\${riskPct.toStringAsFixed(0)}%)',
                        subtitle:
                            '单笔死扛风控: \\\$\${riskAmount.toStringAsFixed(0)} (无保本)',
                        finalBal: simResult!['stFinal'],
                        maxRisk:
                            '\\\$\${riskAmount.toStringAsFixed(0)} (\${riskPct.toStringAsFixed(0)}%)',
                        drawdown: simResult!['stDrawdown'],
                        blowRate: simResult!['stBlowRate'],
                        maxStreak: simResult!['stMaxStreak'],
                        color: const Color(0xFF8B5CF6),
                        isBlownUp: simResult!['stBlownUp'],
                        isDark: isDark,
                      ),
                    ),
                  ],
                ) : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildResultCard(
                      title:
                          'DT 双轨 (2x\${(riskPct / 2).toStringAsFixed(1)}% = \${riskPct.toStringAsFixed(0)}%)',
                      subtitle:
                          '风控: \\\$\${riskAmount.toStringAsFixed(0)} (A:\\\$\${(riskAmount / 2).toStringAsFixed(0)}+B:\\\$\${(riskAmount / 2).toStringAsFixed(0)})',
                      finalBal: simResult!['dtFinal'],
                      maxRisk:
                          '\\\$\${riskAmount.toStringAsFixed(0)} (\${riskPct.toStringAsFixed(0)}%)',
                      drawdown: simResult!['dtDrawdown'],
                      blowRate: simResult!['dtBlowRate'],
                      maxStreak: simResult!['dtMaxStreak'],
                      color: const Color(0xFF10B981),
                      isBlownUp: simResult!['dtBlownUp'],
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildResultCard(
                      title: '传统单轨 (1x\${riskPct.toStringAsFixed(0)}%)',
                      subtitle:
                          '单笔死扛风控: \\\$\${riskAmount.toStringAsFixed(0)} (无保本)',
                      finalBal: simResult!['stFinal'],
                      maxRisk:
                          '\\\$\${riskAmount.toStringAsFixed(0)} (\${riskPct.toStringAsFixed(0)}%)',
                      drawdown: simResult!['stDrawdown'],
                      blowRate: simResult!['stBlowRate'],
                      maxStreak: simResult!['stMaxStreak'],
                      color: const Color(0xFF8B5CF6),
                      isBlownUp: simResult!['stBlownUp'],
                      isDark: isDark,
                    ),
                  ],
                ),''';

  if (content.contains(oldCode)) {
    content = content.replaceFirst(oldCode, newCode);
    file.writeAsStringSync(content);
    print('Replaced successfully!');
  } else {
    print('Could not find old code block!');
    // Let's try matching with regex to ignore whitespace
    var regex = RegExp(r'child:\s*Row\(\s*crossAxisAlignment:\s*CrossAxisAlignment\.start,\s*children:\s*\[\s*Expanded\(\s*child:\s*_buildResultCard\(\s*title:\s*.DT 双轨.*', multiLine: true, dotAll: true);
    if (regex.hasMatch(content)) {
       print('Regex matches!');
    }
  }
}

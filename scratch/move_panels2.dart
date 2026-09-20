import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();

  // 1. Find the block to move
  int mantraStart = lines.indexWhere((l) => l.contains('Widget _buildMantraCard(BuildContext context)'));
  int blueprintEnd = lines.indexWhere((l) => l.contains('Widget _buildBadge(BuildContext context'));
  
  if (mantraStart == -1 || blueprintEnd == -1) {
    print('Failed to find methods!');
    return;
  }
  
  List<String> methodsToMove = lines.sublist(mantraStart, blueprintEnd);
  
  // 2. Remove them from _TpCalculatorPageState
  lines.removeRange(mantraStart, blueprintEnd);
  
  // 3. Remove them from rightChildren
  int call1 = lines.indexWhere((l) => l.contains('_buildMantraCard(context),'));
  if (call1 != -1) lines.removeAt(call1);
  int call2 = lines.indexWhere((l) => l.contains('_buildBlueprintCard(context),'));
  if (call2 != -1) lines.removeAt(call2);
  
  // 4. Inject into _OverlapCheckerPageState
  int classEnd = lines.indexWhere((l) => l.contains('class LotSizeCalcPage'));
  int insertIdx = -1;
  for (int i = classEnd - 1; i >= 0; i--) {
    if (lines[i].trim() == '}') {
      insertIdx = i;
      break;
    }
  }
  
  if (insertIdx == -1) {
    print('Failed to find end of _OverlapCheckerPageState');
    return;
  }
  
  List<String> affiliateBanner = [
    '  Widget _buildXMAffiliateBanner(BuildContext context) {',
    '    return GestureDetector(',
    '      onTap: () {',
    '        // TODO: Insert your actual XM Affiliate Link here',
    '        // launchUrl(Uri.parse(\'https://clicks.pipaffiliates.com/c?c=XXXXX\'));',
    '        ScaffoldMessenger.of(context).showSnackBar(',
    '          const SnackBar(content: Text(\'正在前往 XM 官方认证开户通道...\')),',
    '        );',
    '      },',
    '      child: Container(',
    '        margin: const EdgeInsets.only(bottom: 12),',
    '        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),',
    '        decoration: BoxDecoration(',
    '          gradient: const LinearGradient(',
    '            colors: [Color(0xFF22C55E), Color(0xFF16A34A)],',
    '            begin: Alignment.topLeft,',
    '            end: Alignment.bottomRight,',
    '          ),',
    '          borderRadius: BorderRadius.circular(12),',
    '          boxShadow: [',
    '            BoxShadow(',
    '              color: const Color(0xFF22C55E).withOpacity(0.3),',
    '              blurRadius: 8,',
    '              offset: const Offset(0, 4),',
    '            )',
    '          ],',
    '        ),',
    '        child: Row(',
    '          children: [',
    '            Container(',
    '              padding: const EdgeInsets.all(6),',
    '              decoration: BoxDecoration(',
    '                color: Colors.white.withOpacity(0.2),',
    '                shape: BoxShape.circle,',
    '              ),',
    '              child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),',
    '            ),',
    '            const SizedBox(width: 12),',
    '            const Expanded(',
    '              child: Column(',
    '                crossAxisAlignment: CrossAxisAlignment.start,',
    '                children: [',
    '                  Text(\'XM 官方认证开户通道 (专属活动)\',',
    '                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),',
    '                  SizedBox(height: 2),',
    '                  Text(\'点击立即注册，尊享极低点差与入金赠金\',',
    '                      style: TextStyle(color: Colors.white70, fontSize: 11)),',
    '                ],',
    '              ),',
    '            ),',
    '            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),',
    '          ],',
    '        ),',
    '      ),',
    '    );',
    '  }',
    ''
  ];
  
  lines.insertAll(insertIdx, affiliateBanner);
  lines.insertAll(insertIdx + affiliateBanner.length, methodsToMove);
  
  // 5. Add to ListView in OverlapCheckerPage
  int summaryIdx = lines.indexWhere((l) => l.contains('_buildSummaryPanel(audit),'));
  if (summaryIdx != -1) {
    // summary is conditionally added:
    // if (isComplete) ...[ ... _buildSummaryPanel(audit), ]
    // We want to add our widgets after the if block.
    int endIfIdx = -1;
    for (int i = summaryIdx; i < summaryIdx + 20; i++) {
      if (lines[i].contains(']')) {
        endIfIdx = i;
        break;
      }
    }
    
    if (endIfIdx != -1) {
      lines.insertAll(endIfIdx + 1, [
        '                const SizedBox(height: 24),',
        '                _buildXMAffiliateBanner(context),',
        '                _buildMantraCard(context),',
        '                _buildBlueprintCard(context),',
        '                const SizedBox(height: 40),'
      ]);
    }
  }

  file.writeAsStringSync(lines.join('\\n'));
  print('Successfully refactored layout!');
}

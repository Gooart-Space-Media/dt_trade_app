import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  String content = file.readAsStringSync();

  // 1. Locate the methods to move
  int mantraStart = content.indexOf('Widget _buildMantraCard(BuildContext context) {');
  int blueprintEnd = content.indexOf('Widget _buildPositionSizeTable() {'); // Blueprint ends here
  
  if (mantraStart == -1 || blueprintEnd == -1) {
    print('Failed to find methods!');
    return;
  }
  
  String methodsToMove = content.substring(mantraStart, blueprintEnd);
  
  // 2. Remove them from _TpCalculatorPageState
  content = content.replaceFirst(methodsToMove, '');
  
  // 3. Remove them from TpCalculatorPage's rightChildren
  String oldRightChildren = '''
      final rightChildren = <Widget>[
        _buildMantraCard(context),
        _buildBlueprintCard(context),
''';
  String newRightChildren = '''
      final rightChildren = <Widget>[
''';
  content = content.replaceFirst(oldRightChildren, newRightChildren);
  
  // 4. Inject the methods into _OverlapCheckerPageState
  int overlapEndIdx = content.indexOf('class LotSizeCalcPage extends StatefulWidget {');
  // Find the last closing brace of _OverlapCheckerPageState before LotSizeCalcPage
  int insertIdx = content.lastIndexOf('}', overlapEndIdx - 10);
  
  String affiliateMethod = '''
  Widget _buildXMAffiliateBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Insert your actual XM Affiliate Link here
        // launchUrl(Uri.parse('https://clicks.pipaffiliates.com/c?c=XXXXX'));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正在前往 XM 开户页面...')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('XM 官方认证开户通道 (专属活动)',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text('点击立即注册，尊享极低点差与入金赠金',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
          ],
        ),
      ),
    );
  }

''';

  String finalMethods = affiliateMethod + methodsToMove;
  
  content = content.substring(0, insertIdx) + finalMethods + content.substring(insertIdx);
  
  // 5. Add them to OverlapCheckerPage's build method
  // Let's replace the ListView in OverlapCheckerPage to use a LayoutBuilder for side-by-side on desktop
  // Right now OverlapCheckerPage has: 
  // return Center(child: Container(constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : 750), child: ListView( ... )));
  
  // We need to inject the affiliate banner and the two panels into the OverlapCheckerPage.
  // The easiest way without rewriting the whole layout is just to append them to the existing ListView!
  
  // The ListView in OverlapCheckerPage has:
  //                 if (isComplete) ...[
  //                   const SizedBox(height: 24),
  //                   _buildSummaryPanel(audit),
  //                 ]
  //               ],
  //             )));
  
  String oldListEnd = '''
                if (isComplete) ...[
                  const SizedBox(height: 24),
                  _buildSummaryPanel(audit),
                ]
              ],
            )));
''';

  String newListEnd = '''
                if (isComplete) ...[
                  const SizedBox(height: 24),
                  _buildSummaryPanel(audit),
                ],
                const SizedBox(height: 32),
                _buildXMAffiliateBanner(context),
                _buildMantraCard(context),
                _buildBlueprintCard(context),
                const SizedBox(height: 40),
              ],
            )));
''';

  content = content.replaceFirst(oldListEnd, newListEnd);

  file.writeAsStringSync(content);
  print('Successfully moved methods and updated UI!');
}

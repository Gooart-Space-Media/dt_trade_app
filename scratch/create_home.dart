import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();

  // 1. Locate the methods I just added to OverlapCheckerPage
  int bannerStart = lines.indexWhere((l) => l.contains('Widget _buildXMAffiliateBanner(BuildContext context) {'));
  int blueprintEnd = lines.indexWhere((l) => l.contains('Widget _buildBadge(BuildContext context'));

  if (bannerStart == -1 || blueprintEnd == -1) {
    print('Failed to find the methods to move out of OverlapCheckerPage!');
    return;
  }

  List<String> methodsToMove = lines.sublist(bannerStart, blueprintEnd);
  
  // Update the XM affiliate link inside the banner method!
  for (int i = 0; i < methodsToMove.length; i++) {
    if (methodsToMove[i].contains('// launchUrl(Uri.parse(')) {
      methodsToMove[i] = "        // launchUrl(Uri.parse('https://clicks.pipaffiliates.com/c?c=1302046&l=zh-hans&p=6'));";
    }
  }

  // Remove them from _OverlapCheckerPageState
  lines.removeRange(bannerStart, blueprintEnd);

  // 2. Remove the calls from OverlapCheckerPage's build method
  int bannerCall = lines.indexWhere((l) => l.contains('_buildXMAffiliateBanner(context),'));
  if (bannerCall != -1) {
    // Remove: 
    // const SizedBox(height: 24),
    // _buildXMAffiliateBanner(context),
    // _buildMantraCard(context),
    // _buildBlueprintCard(context),
    // const SizedBox(height: 40),
    lines.removeRange(bannerCall - 1, bannerCall + 4);
  }

  // 3. Create the new HomePage class
  List<String> homePageClass = [
    '// -------------------------------------------------------------',
    '// 0. 首页 (Home Page) - XM Affiliate & Knowledge Base',
    '// -------------------------------------------------------------',
    'class HomePage extends StatelessWidget {',
    '  const HomePage({super.key});',
    '',
    '  @override',
    '  Widget build(BuildContext context) {',
    '    bool isDesktop = MediaQuery.of(context).size.width > 800;',
    '    return Center(',
    '      child: Container(',
    '        constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : 750),',
    '        child: ListView(',
    '          padding: const EdgeInsets.all(16),',
    '          children: [',
    '            _buildXMAffiliateBanner(context),',
    '            _buildMantraCard(context),',
    '            _buildBlueprintCard(context),',
    '          ],',
    '        ),',
    '      ),',
    '    );',
    '  }',
    ''
  ];
  homePageClass.addAll(methodsToMove);
  homePageClass.add('}');
  homePageClass.add('');

  // Insert HomePage right before OverlapCheckerPage
  int overlapPageStart = lines.indexWhere((l) => l.contains('class OverlapCheckerPage extends StatefulWidget {'));
  if (overlapPageStart != -1) {
    // Insert before the comment of OverlapCheckerPage
    int commentStart = overlapPageStart - 3;
    lines.insertAll(commentStart, homePageClass);
  } else {
    print('Failed to find OverlapCheckerPage');
    return;
  }

  // 4. Add HomePage to _pages
  int pagesStart = lines.indexWhere((l) => l.contains('final List<Widget> _pages = const ['));
  if (pagesStart != -1) {
    lines.insert(pagesStart + 1, '    HomePage(),');
  } else {
    print('Failed to find _pages');
    return;
  }

  // 5. Add NavigationDestination to NavigationBar
  int navDestinations = lines.indexWhere((l) => l.contains('destinations: const ['));
  if (navDestinations != -1) {
    lines.insertAll(navDestinations + 1, [
      '          NavigationDestination(',
      '            icon: Icon(Icons.home_outlined),',
      '            selectedIcon: Icon(Icons.home_rounded),',
      '            label: \'首页\',',
      '          ),'
    ]);
  } else {
    print('Failed to find NavigationBar destinations');
    return;
  }

  file.writeAsStringSync(lines.join('\n'));
  print('Successfully created HomePage with XM links!');
}

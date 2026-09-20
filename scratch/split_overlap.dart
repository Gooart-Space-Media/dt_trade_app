import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();

  // Find OverlapCheckerPageState
  int start = lines.indexWhere((l) => l.contains('class _OverlapCheckerPageState'));
  int build = lines.indexWhere((l) => l.contains('Widget build(BuildContext context) {'), start);
  
  // Find the exact line "return Center("
  int returnCenter = lines.indexWhere((l) => l.contains('return Center('), build);
  
  // Find the "children: [" array of the ListView
  int listViewChildren = lines.indexWhere((l) => l.contains('children: ['), returnCenter);

  // Find the split point: "if (isComplete) ...["
  int splitPoint = lines.indexWhere((l) => l.contains('if (isComplete) ...['), listViewChildren);

  // Find the end of the children array
  // The structure is:
  // if (isComplete) ...[
  //   _buildAlertCard(audit),
  //   _buildRuleCard(),
  //   _buildChecklist(audit),
  //   const SizedBox(height: 12),
  // ]
  int splitEnd = splitPoint + 5;
  while (!lines[splitEnd].trim().endsWith(']')) {
    splitEnd++;
  }
  // The ']' line is the end of the if(isComplete) array. The next line is the end of children array ']'
  
  // Let's modify the build method to use LayoutBuilder
  lines[returnCenter] = '    return LayoutBuilder(builder: (context, constraints) {';
  lines.insert(returnCenter + 1, '      bool isDesktop = constraints.maxWidth > 800;');
  lines.insert(returnCenter + 2, '      List<Widget> leftContent = [');

  // Skip the 'child: ListView(' and 'padding:' and 'children: ['
  for (int i = returnCenter + 3; i <= listViewChildren; i++) {
    lines[i] = '      // removed ' + lines[i].trim();
  }

  // Replace split point
  lines.insert(splitPoint, '      ];');
  lines.insert(splitPoint + 1, '      List<Widget> rightContent = [');
  
  // Since we shifted the array, we need to adjust splitEnd index by 2
  splitEnd += 2;

  // Wait, there's a ']' that closes the original 'children: [' right after splitEnd.
  int childrenEnd = splitEnd + 1;
  while (lines[childrenEnd].trim() != ']') {
    childrenEnd++;
  }

  // We replace from childrenEnd to the end of the return statement
  int returnEnd = childrenEnd;
  while (lines[returnEnd].trim() != '}' && lines[returnEnd-1].trim() != '}' && lines[returnEnd-2].trim() != ';') {
    returnEnd++;
  }
  // Let's just find the next method:
  int nextMethod = lines.indexWhere((l) => l.contains('Widget _buildDropdownRow'), returnEnd);
  int actualReturnEnd = nextMethod - 1;
  while(lines[actualReturnEnd].trim() != '}') actualReturnEnd--;

  // Replace from childrenEnd to actualReturnEnd
  lines.removeRange(childrenEnd, actualReturnEnd);
  lines.insert(childrenEnd, '''
      ];

      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.all(10),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: leftContent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 6,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: rightContent,
                        ),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [...leftContent, ...rightContent],
                  ),
                ),
        ),
      );
    });
''');

  file.writeAsStringSync(lines.join('\n'));
  print('OverlapCheckerPage layout split applied!');
}

import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();

  // 1. OverlapCheckerPage
  int overlapStart = lines.indexWhere((l) => l.contains('class _OverlapCheckerPageState'));
  int overlapBuild = lines.indexWhere((l) => l.contains('Widget build(BuildContext context) {'), overlapStart);
  int overlapReturn = lines.indexWhere((l) => l.contains('return Center('), overlapBuild);
  int overlapListView = lines.indexWhere((l) => l.contains('child: ListView('), overlapReturn);
  int overlapChildren = lines.indexWhere((l) => l.contains('children: ['), overlapListView);

  int overlapEnd = lines.indexWhere((l) => l.contains('class LotSizeCalcPage'), overlapBuild);
  int overlapBrace = -1;
  for (int i = overlapEnd - 1; i > overlapBuild; i--) {
    if (lines[i].trim() == '}') {
      if (lines[i-1].trim() == '}' || lines[i-1].trim() == ');') {
        overlapBrace = i - 6; // approximate end of return
        break;
      }
    }
  }

  // 2. SurvivalSimulatorPage
  int simStart = lines.indexWhere((l) => l.contains('class _SurvivalSimulatorPageState'));
  int simBuild = lines.indexWhere((l) => l.contains('Widget build(BuildContext context) {'), simStart);
  int simReturn = lines.indexWhere((l) => l.contains('return Center('), simBuild);
  int simListView = lines.indexWhere((l) => l.contains('child: ListView('), simReturn);
  
  // Update Simulator chart height
  for (int i = simBuild; i < simBuild + 600; i++) {
    if (lines[i].contains('height: 220,')) {
      lines[i] = '            height: isDesktop ? 220 : 308,';
    }
  }

  // Split logic for Overlap
  int overlapComplete = lines.indexWhere((l) => l.contains('if (isComplete) ...['), overlapChildren);
  if (overlapComplete != -1) {
    lines.insert(overlapComplete, '      ];');
    lines.insert(overlapComplete + 1, '      List<Widget> rightContent = [');
  }

  // Split logic for Sim
  int simInfoBox = lines.indexWhere((l) => l.contains('if (hasRun) _buildInfoBox(),'), simListView);
  if (simInfoBox != -1) {
    // Info box is right after the result cards and some spacing.
    // Let's find the result cards ending.
    int resultCardsEnd = simInfoBox - 1;
    while (!lines[resultCardsEnd].contains('const SizedBox(height: 24),')) {
      resultCardsEnd--;
    }
    lines.insert(resultCardsEnd + 1, '      ];');
    lines.insert(resultCardsEnd + 2, '      List<Widget> rightContent = [');
  }

  // Now replace the top part of the builds
  for (int i = 0; i < lines.length; i++) {
    if (i == overlapReturn) {
      lines[i] = '    return LayoutBuilder(builder: (context, constraints) {';
      lines.insert(i+1, '      bool isDesktop = constraints.maxWidth > 800;');
      lines.insert(i+2, '      List<Widget> leftContent = [');
    }
    if (i == overlapListView) {
      lines[i] = '      // removed listview';
    }
    if (i == overlapChildren) {
      lines[i] = '      // removed children';
    }
    if (i == overlapBrace) {
      // Need to replace the end of Overlap return
      lines[i] = '''
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
''';
    }

    if (i == simReturn) {
      lines[i] = '    return LayoutBuilder(builder: (context, constraints) {';
      lines.insert(i+1, '      bool isDesktop = constraints.maxWidth > 800;');
      lines.insert(i+2, '      List<Widget> leftContent = [');
    }
    if (i == simListView) {
      lines[i] = '      // removed listview';
    }
    if (i == simListView + 1 && lines[i].contains('padding:')) {
      lines[i] = '      // removed padding';
    }
    if (i == simListView + 2 && lines[i].contains('children:')) {
      lines[i] = '      // removed children';
    }

    if (i == simListView + 500 && lines[i].contains('return Center(')) { // won't hit
    }
  }

  // Need to find Sim end
  int simEndBrace = -1;
  int tpCalc = lines.indexWhere((l) => l.contains('class TpCalculatorPage'));
  for (int i = tpCalc - 1; i > simBuild; i--) {
    if (lines[i].trim() == '}') {
      if (lines[i-1].trim() == '}' || lines[i-1].trim() == ');') {
        simEndBrace = i - 6; 
        break;
      }
    }
  }

  // Wait, doing this via script without an AST parser on a 7000 line file is extremely dangerous and could corrupt the brackets easily.
  // Instead, I will write the WHOLE `OverlapCheckerPage` and `SurvivalSimulatorPage` classes via `replace_file_content`.
}

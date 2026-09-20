import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();

  // 1. Rewrite _SurvivalSimulatorPageState build method
  int simStart = lines.indexWhere((l) => l.contains('class _SurvivalSimulatorPageState extends State<SurvivalSimulatorPage>'));
  int simBuild = lines.indexWhere((l) => l.contains('Widget build(BuildContext context) {'), simStart);
  int simEnd = lines.indexWhere((l) => l.contains('class TpCalculatorPage'), simBuild); // End of Simulator

  // We find the return Center( ... child: ListView( ... ))
  int simReturn = lines.indexWhere((l) => l.contains('return Center('), simBuild);
  int simListView = lines.indexWhere((l) => l.contains('ListView('), simReturn);

  // Everything inside the ListView children array...
  int childrenStart = lines.indexWhere((l) => l.contains('children: ['), simListView) + 1;
  
  // The children end at the end of the return statement
  int childrenEnd = -1;
  for (int i = simListView; i < simEnd; i++) {
    if (lines[i].trim() == '  }' && lines[i+1].trim() == '') {
      childrenEnd = i - 6; // approximate, just before return closing braces
      break;
    }
  }

  // Actually, rewriting the whole build method is safer:
  List<String> simBuildNew = [
    '  @override',
    '  Widget build(BuildContext context) {',
    '    return LayoutBuilder(builder: (context, constraints) {',
    '      bool isDesktop = constraints.maxWidth > 800;',
    '      List<Widget> leftContent = [',
    '        const SizedBox(height: 12),',
    '        const Row(',
    '          children: [',
    '            Icon(Icons.auto_graph_rounded, color: Color(0xFFF59E0B), size: 24),',
    '            SizedBox(width: 8),',
    '            Expanded(',
    '              child: Text(\'蒙特卡洛 12 个月复利与走势演练\',',
    '                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B))),',
    '            ),',
    '          ],',
    '        ),',
    '        const SizedBox(height: 8),',
    '        Text(\'用客观概率打破赌徒侥幸心理。模拟连续12个月后资金曲线，直观感受风控红线的威力和回撤规律。\',',
    '            style: TextStyle(fontSize: 11, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), height: 1.5)),',
    '        const SizedBox(height: 16),',
    '        _buildInputs(),',
    '        const SizedBox(height: 16),',
    '        ElevatedButton.icon(',
    '          style: ElevatedButton.styleFrom(',
    '            backgroundColor: const Color(0xFF475569),',
    '            foregroundColor: Colors.white,',
    '            padding: const EdgeInsets.symmetric(vertical: 14),',
    '            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),',
    '            elevation: 0,',
    '          ),',
    '          onPressed: () {',
    '            runSimulation();',
    '            _scrollToBottom();',
    '          },',
    '          icon: const Icon(Icons.casino_rounded, size: 20),',
    '          label: const Text(\'运行 12 个月实战走势推演\', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),',
    '        ),',
    '        const SizedBox(height: 24),',
    '        if (hasRun)',
    '          Row(',
    '            crossAxisAlignment: CrossAxisAlignment.start,',
    '            children: [',
    '              Expanded(',
    '                child: _buildResultCard(',
    '                  title: \'DT 双轨 (\${(risk / 2).toStringAsFixed(1)}% + \${(risk / 2).toStringAsFixed(1)}% = \$risk%)\',',
    '                  subtitle: \'风控: \\\$\${(balance * risk / 100).toStringAsFixed(0)} (A:\\\$\${(balance * (risk / 2) / 100).toStringAsFixed(0)}+B:\\\$\${(balance * (risk / 2) / 100).toStringAsFixed(0)})\',',
    '                  finalBal: finalBalDT,',
    '                  maxRisk: \'\${risk.toStringAsFixed(1)}%\',',
    '                  drawdown: maxDrawdownDT,',
    '                  blowRate: blownUpDT ? 100.0 : 0.0,',
    '                  maxStreak: maxLosingStreakDT,',
    '                  color: const Color(0xFF10B981),',
    '                  isBlownUp: blownUpDT,',
    '                  isDark: Theme.of(context).brightness == Brightness.dark,',
    '                ),',
    '              ),',
    '              const SizedBox(width: 8),',
    '              Expanded(',
    '                child: _buildResultCard(',
    '                  title: \'传统单轨 (\$risk%)\',',
    '                  subtitle: \'风控: \\\$\${(balance * risk / 100).toStringAsFixed(0)} (单一入场)\',',
    '                  finalBal: finalBalST,',
    '                  maxRisk: \'\${risk.toStringAsFixed(1)}%\',',
    '                  drawdown: maxDrawdownST,',
    '                  blowRate: blownUpST ? 100.0 : 0.0,',
    '                  maxStreak: maxLosingStreakST,',
    '                  color: const Color(0xFF8B5CF6),',
    '                  isBlownUp: blownUpST,',
    '                  isDark: Theme.of(context).brightness == Brightness.dark,',
    '                ),',
    '              ),',
    '            ],',
    '          ),',
    '        const SizedBox(height: 24),',
    '      ];',
    '      List<Widget> rightContent = [',
    '        const SizedBox(height: 12),',
    '        if (hasRun) _buildInfoBox(),',
    '        const SizedBox(height: 24),',
    '        if (hasRun) ...[',
    '          const Text(\'📈 账户净值走势 (红线单轨 vs 绿线双轨)\',',
    '              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),',
    '          const SizedBox(height: 16),',
    '          Container(',
    '            height: isDesktop ? 220 : 308, // Increased by 40% on mobile (220 * 1.4 = 308)',
    '            padding: const EdgeInsets.only(right: 20, left: 0, top: 20, bottom: 10),',
    '            decoration: BoxDecoration(',
    '              color: Theme.of(context).cardColor,',
    '              borderRadius: BorderRadius.circular(16),',
    '              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),',
    '            ),',
    '            child: LineChart(_buildChartData()),',
    '          ),',
    '          const SizedBox(height: 24),',
    '          const Text(\'🗓️ 逐月复利明细 (单轨 vs 双轨)\',',
    '              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),',
    '          const SizedBox(height: 12),',
    '          _buildGrid(isDesktop),',
    '          const SizedBox(height: 40),',
    '        ]',
    '      ];',
    '      return Center(',
    '        child: Container(',
    '          constraints: const BoxConstraints(maxWidth: 1200),',
    '          padding: const EdgeInsets.symmetric(horizontal: 16),',
    '          child: isDesktop',
    '            ? Row(',
    '                crossAxisAlignment: CrossAxisAlignment.start,',
    '                children: [',
    '                  Expanded(flex: 5, child: SingleChildScrollView(controller: _scrollController, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: leftContent))),',
    '                  const SizedBox(width: 16),',
    '                  Expanded(flex: 6, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rightContent))),',
    '                ],',
    '              )',
    '            : SingleChildScrollView(',
    '                controller: _scrollController,',
    '                child: Column(',
    '                  crossAxisAlignment: CrossAxisAlignment.stretch,',
    '                  children: [...leftContent, ...rightContent],',
    '                ),',
    '              ),',
    '        ),',
    '      );',
    '    });',
    '  }'
  ];

  // We find the end of the original build method
  int endSimBuild = lines.indexWhere((l) => l.contains('Widget _buildInputs()'), simBuild);
  lines.replaceRange(simBuild - 1, endSimBuild, simBuildNew);

  file.writeAsStringSync(lines.join('\n'));
  print('Replaced SurvivalSimulatorPage build method!');
}

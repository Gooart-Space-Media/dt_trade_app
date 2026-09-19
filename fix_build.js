const fs = require('fs');
let oldBuild = fs.readFileSync('scratch/new_build.dart', 'utf-8');

// 1. Tighten spacings
oldBuild = oldBuild.replace(/const SizedBox\(height: 24\)/g, 'const SizedBox(height: 8)');
oldBuild = oldBuild.replace(/const SizedBox\(height: 16\)/g, 'const SizedBox(height: 8)');
oldBuild = oldBuild.replace(/const SizedBox\(height: 12\)/g, 'const SizedBox(height: 4)');
oldBuild = oldBuild.replace(/const SizedBox\(height: 10\)/g, 'const SizedBox(height: 4)');

// 2. Make TextFields dense
const decoration = `decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),`;
oldBuild = oldBuild.replace(/decoration: InputDecoration\(/g, decoration);

// 3. Make Run button smaller padding
oldBuild = oldBuild.replace(/padding: const EdgeInsets\.symmetric\(vertical: 14\)/g, 'padding: const EdgeInsets.symmetric(vertical: 8)');

// 4. Tighten result card padding
oldBuild = oldBuild.replace(/padding: const EdgeInsets\.all\(12\)/g, 'padding: const EdgeInsets.all(8)');

// 5. Change Chart height to Expanded
oldBuild = oldBuild.replace(/Container\(\s*height: 160,\s*margin: const EdgeInsets\.symmetric\(horizontal: 12\),\s*padding: const EdgeInsets\.all\(8\),\s*decoration: BoxDecoration\([\s\S]*?child: CustomPaint\([\s\S]*?dtBlownUp: simResult!\['dtBlownUp'\] as bool,\s*stBlownUp: simResult!\['stBlownUp'\] as bool,\s*\),\s*\),\s*\),/m, 
`Expanded(
  child: Container(
    margin: const EdgeInsets.symmetric(horizontal: 12),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
    ),
    child: CustomPaint(
      painter: DualEquityCurvePainter(
        dtPoints: simResult!['dtEquity'] as List<double>,
        stPoints: simResult!['stEquity'] as List<double>,
        dtBlownUp: simResult!['dtBlownUp'] as bool,
        stBlownUp: simResult!['stBlownUp'] as bool,
      ),
    ),
  ),
),`);

// 6. Update LayoutBuilder to use stretch and no ScrollViews for desktop
const desktopLayout = `
        if (constraints.maxWidth > 800) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: leftContent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: rightContent,
                ),
              ],
            ),
          );
`;
oldBuild = oldBuild.replace(/if \(constraints\.maxWidth > 800\) \{[\s\S]*?\} else \{/m, desktopLayout + '} else {');

// Combine the two rows of inputs into one if desktop
const inputRow1Match = oldBuild.match(/Row\([\s\S]*?_winCtrl[\s\S]*?\},[\s\S]*?\),[\s\S]*?\),[\s\S]*?\],[\s\S]*?\),/);
const inputRow2Match = oldBuild.match(/Row\([\s\S]*?_riskCtrl[\s\S]*?\},[\s\S]*?\),[\s\S]*?\],[\s\S]*?\),/);

if (inputRow1Match && inputRow2Match) {
  const inputRow1 = inputRow1Match[0];
  const inputRow2 = inputRow2Match[0];

  const combinedInputs = `
            constraints.maxWidth > 800 
            ? Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _balCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), labelText: '本金(USD)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      onChanged: (v) { startBal = double.tryParse(v) ?? 700; SharedPreferences.getInstance().then((p) => p.setDouble('sim_bal', startBal)); },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextFormField(
                      controller: _winCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), labelText: '胜率(%)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      onChanged: (v) { winRate = double.tryParse(v) ?? 50; SharedPreferences.getInstance().then((p) => p.setDouble('sim_win', winRate)); },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextFormField(
                      controller: _riskCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), labelText: '风险(%)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      onChanged: (v) { riskPct = double.tryParse(v) ?? 2; SharedPreferences.getInstance().then((p) => p.setDouble('sim_risk', riskPct)); },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      value: rr,
                      decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), labelText: '盈亏比', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      items: const [
                        DropdownMenuItem(value: 1.0, child: Text('1:1')),
                        DropdownMenuItem(value: 1.5, child: Text('1:1.5')),
                        DropdownMenuItem(value: 2.0, child: Text('1:2')),
                        DropdownMenuItem(value: 3.0, child: Text('1:3')),
                      ],
                      onChanged: (v) { setState(() => rr = v ?? 2.0); SharedPreferences.getInstance().then((p) => p.setDouble('sim_rr', rr)); },
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  ${inputRow1},
                  const SizedBox(height: 4),
                  ${inputRow2},
                ]
              ),`;

  const originalInputsRegex = /Row\([\s\S]*?_winCtrl[\s\S]*?\},[\s\S]*?\),[\s\S]*?\),[\s\S]*?\],[\s\S]*?\),\s*const SizedBox\(height: 4\),\s*Row\([\s\S]*?_riskCtrl[\s\S]*?\},[\s\S]*?\),[\s\S]*?\],[\s\S]*?\),/;
  oldBuild = oldBuild.replace(originalInputsRegex, combinedInputs);
}

oldBuild = oldBuild.replace(/padding: const EdgeInsets\.all\(12\),\s*child: Row\([\s\S]*?双轨分仓 vs 传统单轨/, 
`padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.compare_arrows, color: Colors.blueAccent, size: 16),
                      const SizedBox(width: 6),
                      const Expanded(child: Text('双轨分仓 vs 传统单轨 12个月实战对比',`);

oldBuild = oldBuild.replace(/padding: const EdgeInsets\.symmetric\(horizontal: 12, vertical: 10\),\s*color: Colors\.blueAccent\.withOpacity/,
`padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  color: Colors.blueAccent.withOpacity`);

let mainCode = fs.readFileSync('lib/main.dart', 'utf-8');
const lines = mainCode.split('\n');
const start = lines.findIndex((l, i) => i > 3700 && l.includes('Widget build(BuildContext context) {'));
const end = lines.findIndex((l, i) => i > start && l.includes('Widget _buildLegend(Color color, String text) {'));

mainCode = lines.slice(0, start).join('\n') + '\n' + oldBuild + '\n' + lines.slice(end).join('\n');
fs.writeFileSync('lib/main.dart', mainCode);
console.log('Fixed build method!');

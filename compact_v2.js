const fs = require('fs');
let code = fs.readFileSync('scratch/new_build_compact.dart', 'utf-8');

// Combine the two rows of inputs into one if desktop
const inputRow1Match = code.match(/Row\([\s\S]*?_winCtrl[\s\S]*?\},[\s\S]*?\),[\s\S]*?\),[\s\S]*?\],[\s\S]*?\),/);
const inputRow2Match = code.match(/Row\([\s\S]*?_riskCtrl[\s\S]*?\},[\s\S]*?\),[\s\S]*?\],[\s\S]*?\),/);

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
              ),
`;

  const originalInputsRegex = /Row\([\s\S]*?_winCtrl[\s\S]*?\},[\s\S]*?\),[\s\S]*?\),[\s\S]*?\],[\s\S]*?\),\s*const SizedBox\(height: 4\),\s*Row\([\s\S]*?_riskCtrl[\s\S]*?\},[\s\S]*?\),[\s\S]*?\],[\s\S]*?\),/;
  code = code.replace(originalInputsRegex, combinedInputs);
}

// Also remove the SingleChildScrollView wrapper for leftContent in desktop mode!
code = code.replace(/child: SingleChildScrollView\(child: leftContent\),/g, 'child: leftContent,');

code = code.replace(/padding: const EdgeInsets\.all\(12\),\s*child: Row\([\s\S]*?双轨分仓 vs 传统单轨/, 
`padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.compare_arrows, color: Colors.blueAccent, size: 16),
                      const SizedBox(width: 6),
                      const Expanded(child: Text('双轨分仓 vs 传统单轨 12个月实战对比',`);

code = code.replace(/padding: const EdgeInsets\.symmetric\(horizontal: 12, vertical: 10\),\s*color: Colors\.blueAccent\.withOpacity/,
`padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  color: Colors.blueAccent.withOpacity`);

fs.writeFileSync('scratch/new_build_compact_v2.dart', code);
console.log('Done v2!');

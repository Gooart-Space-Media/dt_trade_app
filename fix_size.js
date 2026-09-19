const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// 1. Remove Expanded around Chart in resultsRight, give it fixed height
code = code.replace(/Expanded\(\s*child: Container\(\s*margin: const EdgeInsets\.symmetric\(horizontal: 12\),[\s\S]*?child: CustomPaint\([\s\S]*?\),\s*\),\s*\),/m, match => {
    return match.replace(/Expanded\(\s*child: /, '').replace(/child: CustomPaint/, 'height: 200, child: CustomPaint').replace(/\),\s*\),\s*$/, '),');
});

// 2. Remove Expanded around resultsLeft padding
code = code.replace(/Expanded\(\s*child: Padding\(\s*padding: const EdgeInsets\.all\(12\),\s*child: Row\(/m, match => {
    return match.replace(/Expanded\(\s*child: /, '').replace(/child: Row\(/, 'child: IntrinsicHeight(\n                  child: Row(').replace(/\]\s*\),\s*\),\s*$/, ']\n                  ),\n                ),');
});

// 3. Compact _buildResultCard
code = code.replace(/padding: const EdgeInsets\.all\(16\)/, "padding: const EdgeInsets.all(10)");
code = code.replace(/fontSize: 28/, "fontSize: 22");
code = code.replace(/const Padding\(padding: EdgeInsets\.symmetric\(vertical: 12\), child: Divider\(height: 1, thickness: 1\)\),/g, "const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Divider(height: 1, thickness: 1)),");
code = code.replace(/const SizedBox\(height: 6\),/g, "const SizedBox(height: 4),");
// Remove Spacer from card
code = code.replace(/const Spacer\(\),/g, "const SizedBox(height: 6),");


// 4. Wrap Desktop layout in SingleChildScrollView and remove Expanded from Row
code = code.replace(/if \(isDesktop\) \{[\s\S]*?return Padding\([\s\S]*?child: Column\([\s\S]*?children: \[[\s\S]*?topControls,[\s\S]*?if \(simResult != null\) \.\.\.\[[\s\S]*?const SizedBox\(height: 16\),[\s\S]*?Expanded\([\s\S]*?child: Row\([\s\S]*?children: \[[\s\S]*?Expanded\(flex: 1, child: resultsLeft\),[\s\S]*?const SizedBox\(width: 16\),[\s\S]*?Expanded\(flex: 1, child: resultsRight\),[\s\S]*?\],[\s\S]*?\),[\s\S]*?\),[\s\S]*?\][\s\S]*?\],[\s\S]*?\),[\s\S]*?\);[\s\S]*?\} else \{/m, 
`if (isDesktop) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                topControls,
                if (simResult != null) ...[
                  const SizedBox(height: 16),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 1, child: resultsLeft),
                        const SizedBox(width: 16),
                        Expanded(flex: 1, child: resultsRight),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          );
        } else {`);

fs.writeFileSync('lib/main.dart', code);
console.log('Fixed sizes and scroll');

const fs = require('fs');
let code = fs.readFileSync('scratch/new_build.dart', 'utf-8');

// 1. Tighten spacings
code = code.replace(/const SizedBox\(height: 24\)/g, 'const SizedBox(height: 8)');
code = code.replace(/const SizedBox\(height: 16\)/g, 'const SizedBox(height: 8)');
code = code.replace(/const SizedBox\(height: 12\)/g, 'const SizedBox(height: 4)');
code = code.replace(/const SizedBox\(height: 10\)/g, 'const SizedBox(height: 4)');

// 2. Make TextFields dense
const decoration = `decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),`;
code = code.replace(/decoration: InputDecoration\(/g, decoration);

// 3. Make Run button smaller padding
code = code.replace(/padding: const EdgeInsets\.symmetric\(vertical: 14\)/g, 'padding: const EdgeInsets.symmetric(vertical: 8)');

// 4. Tighten result card padding
code = code.replace(/padding: const EdgeInsets\.all\(12\)/g, 'padding: const EdgeInsets.all(8)');

// 5. Change Chart height to Expanded
code = code.replace(/Container\(\s*height: 160,\s*margin: const EdgeInsets\.symmetric\(horizontal: 12\),\s*padding: const EdgeInsets\.all\(8\),\s*decoration: BoxDecoration\([\s\S]*?child: CustomPaint\([\s\S]*?dtBlownUp: simResult!\['dtBlownUp'\] as bool,\s*stBlownUp: simResult!\['stBlownUp'\] as bool,\s*\),\s*\),\s*\),/m, 
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
                  child: SingleChildScrollView(child: leftContent), // actually, we should let leftContent be unscrollable if it fits, but what if it doesn't? let's keep SingleChildScrollView for left, it's safer. Wait, if we use SingleChildScrollView for Left, but we want the Right to stretch, the Row's crossAxisAlignment MUST be stretch.
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: rightContent, // Right content is stretched to fill the height, which allows Expanded chart to work!
                ),
              ],
            ),
          );
`;
code = code.replace(/if \(constraints\.maxWidth > 800\) \{[\s\S]*?\} else \{/m, desktopLayout + '} else {');

fs.writeFileSync('scratch/new_build_compact.dart', code);
console.log('Compacted!');

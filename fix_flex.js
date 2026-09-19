const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// 1. Restore the description
code = code.replace(/desc: '',/, "desc: '用客观概率打破赌徒侥幸心理。模拟连续12个月后资金曲线，直观感受风控红线的威力和回撤规律。',");

// Wait, earlier I also removed the usage of desc in _buildBanner!
// We need to restore it.
code = code.replace(/Widget _buildBanner\(\{[\s\S]*?\}\) \{[\s\S]*?return Container\([\s\S]*?children: \[\s*Row\([\s\S]*?\]\),\s*\]\),\s*\);/m, match => {
  // We need to inject the desc Text back.
  return match.replace(/\]\),\s*\]\),\s*\);/, `]),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(desc, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8), height: 1.4)),
          ],
        ],
      ),
    );`);
});


// 2. Change flex from 5,6 to 6,4
code = code.replace(/Expanded\(\s*flex: 5,\s*child: leftContent,\s*\),\s*const SizedBox\(width: 12\),\s*Expanded\(\s*flex: 6,/m, 
`Expanded(
                  flex: 6,
                  child: leftContent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,`);

// 3. Make leftContent scale down if it's too tall!
// We can wrap leftContent in a FittedBox, but we need to give it a constrained width.
// Instead of a FittedBox, I will wrap leftContent inside a LayoutBuilder and SingleChildScrollView for the left side if we don't want it to overflow, but user hates scroll.
// Let's use FittedBox!
code = code.replace(/Expanded\(\s*flex: 6,\s*child: leftContent,\s*\),/m, 
`Expanded(
                  flex: 6,
                  child: LayoutBuilder(
                    builder: (context, leftConstraints) {
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: leftConstraints.maxWidth,
                          child: leftContent,
                        ),
                      );
                    }
                  ),
                ),`);


fs.writeFileSync('lib/main.dart', code);
console.log('Fixed flex and desc');

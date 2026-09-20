const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

const targetStr = `          // 顶部：大马时间盘口时段雷达条（附动态倒计时）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: (session['color'] as Color).withOpacity(0.08),
              border: Border(bottom: BorderSide(color: (session['color'] as Color).withOpacity(0.2))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: session['color'] as Color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('MY $timeStr', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(session['status'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: session['color'] as Color)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: (session['color'] as Color).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: (session['color'] as Color).withOpacity(0.25)),
                            ),
                            child: Text(
                              session['countdown'] as String,
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: session['color'] as Color),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(session['desc'] as String, style: TextStyle(fontSize: 10, color: (session['color'] as Color).withOpacity(0.85)), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),`;

const replacement = `          // 顶部：大马时间盘口时段雷达条（附动态倒计时）
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              _showRadarBottomSheet(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: (session['color'] as Color).withOpacity(0.08),
                border: Border(bottom: BorderSide(color: (session['color'] as Color).withOpacity(0.2))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: session['color'] as Color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('MY \${timeStr}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final topRowChildren = [
                          Text(session['status'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: session['color'] as Color)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: (session['color'] as Color).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: (session['color'] as Color).withOpacity(0.25)),
                            ),
                            child: Text(
                              session['countdown'] as String,
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: session['color'] as Color),
                            ),
                          ),
                        ];

                        if (constraints.maxWidth > 500) {
                          // Desktop: single line
                          return Row(
                            children: [
                              ...topRowChildren,
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(session['desc'] as String, style: TextStyle(fontSize: 10, color: (session['color'] as Color).withOpacity(0.85)), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          );
                        } else {
                          // Mobile: two lines
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: topRowChildren),
                              const SizedBox(height: 2),
                              Text(session['desc'] as String, style: TextStyle(fontSize: 10, color: (session['color'] as Color).withOpacity(0.85)), overflow: TextOverflow.ellipsis),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, size: 16, color: (session['color'] as Color).withOpacity(0.5)),
                ],
              ),
            ),
          ),`;

if (code.includes(targetStr)) {
  code = code.replace(targetStr, replacement);
  fs.writeFileSync('lib/main.dart', code);
  console.log('Successfully replaced top banner!');
} else {
  console.log('Target string not found!');
  // fallback check line by line?
}

const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// The block we want to replace starts around line 483
// It looks like:
/*
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
                    child: Text('MY ${timeStr}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final topRowChildren = [
                          Text(session['status'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: session['color'] as Color)),
*/

let searchBlock = `              decoration: BoxDecoration(
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
                          return Row(
                            children: [
                              ...topRowChildren,
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(session['desc'] as String, style: TextStyle(fontSize: 10, color: (session['color'] as Color).withOpacity(0.85)), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: topRowChildren),
                            const SizedBox(height: 2),
                            Text(session['desc'] as String, style: TextStyle(fontSize: 10, color: (session['color'] as Color).withOpacity(0.85)), overflow: TextOverflow.ellipsis),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                ],
              ),
            ),`;

let replaceBlock = `              child: Builder(
                builder: (ctx) {
                  Color sColor = session['color'] as Color;
                  if (Theme.of(ctx).brightness == Brightness.dark && 
                      (sColor == const Color(0xFF475569) || sColor == const Color(0xFF64748B))) {
                    sColor = Colors.white70;
                  }
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sColor.withOpacity(0.08),
                      border: Border(bottom: BorderSide(color: sColor.withOpacity(0.2))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: sColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('MY \${timeStr}', style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark && sColor == Colors.white70 ? const Color(0xFF1E293B) : Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final topRowChildren = [
                                Text(session['status'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: sColor)),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: sColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: sColor.withOpacity(0.25)),
                                  ),
                                  child: Text(
                                    session['countdown'] as String,
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: sColor),
                                  ),
                                ),
                              ];

                              if (constraints.maxWidth > 500) {
                                return Row(
                                  children: [
                                    ...topRowChildren,
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(session['desc'] as String, style: TextStyle(fontSize: 10, color: sColor.withOpacity(0.85)), overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: topRowChildren),
                                  const SizedBox(height: 2),
                                  Text(session['desc'] as String, style: TextStyle(fontSize: 10, color: sColor.withOpacity(0.85)), overflow: TextOverflow.ellipsis),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                      ],
                    ),
                  );
                }
              ),`;

code = code.replace(searchBlock, replaceBlock);
// wait, we also need to remove the Container wrapper in the original code.
// Let's check what it originally wrapped.
// InkWell( child: Container( padding: ... ) )
// My replaceBlock starts from `              child: Builder(`
// Wait, the original started from `              decoration: BoxDecoration(`.
// I need to search for the whole Container block inside InkWell.
fs.writeFileSync('scratch/test_replace.js', `console.log(code.includes("              decoration: BoxDecoration("));`);
fs.writeFileSync('lib/main.dart', code);
console.log('Fixed banner text color');

const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

const oldSession = `                      Row(
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
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(session['desc'] as String, style: TextStyle(fontSize: 10, color: (session['color'] as Color).withOpacity(0.85)), overflow: TextOverflow.ellipsis),`;

const newSession = `                      Row(
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
                      ),`;

if (code.includes(oldSession)) {
    code = code.replace(oldSession, newSession);
    fs.writeFileSync('lib/main.dart', code);
    console.log('Done session bar');
} else {
    console.log('Could not find oldSession');
}

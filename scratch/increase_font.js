const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf8');

// XM Banner Title
code = code.replace("fontSize: 13,\n                          fontWeight: FontWeight.bold)),", "fontSize: 14,\n                          fontWeight: FontWeight.bold)),");
// XM Banner Desc
code = code.replace("style: TextStyle(color: Colors.white70, fontSize: 11)),", "style: TextStyle(color: Colors.white70, fontSize: 12)),");

// Mantra Card Title
code = code.replace("fontSize: 13,\n                        fontWeight: FontWeight.bold,\n                        color: Theme.of(context).brightness == Brightness.dark\n                            ? const Color(0xFFFDBA74)\n                            : const Color(0xFF9A3412))),", 
                    "fontSize: 14,\n                        fontWeight: FontWeight.bold,\n                        color: Theme.of(context).brightness == Brightness.dark\n                            ? const Color(0xFFFDBA74)\n                            : const Color(0xFF9A3412))),");

// Mantra Line
code = code.replace("fontSize: 11.5,\n              height: 1.4,\n              color: Theme.of(context).brightness == Brightness.dark\n                  ? Colors.white70\n                  : const Color(0xFF431407)),", 
                    "fontSize: 13,\n              height: 1.4,\n              color: Theme.of(context).brightness == Brightness.dark\n                  ? Colors.white70\n                  : const Color(0xFF431407)),");

// Blueprint Title
code = code.replace("TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),", "TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),");

// Blueprint Tag Multi-K
code = code.replace("fontSize: 10,\n                        color: Color(0xFF166534),\n                        fontWeight: FontWeight.bold)),", 
                    "fontSize: 11,\n                        color: Color(0xFF166534),\n                        fontWeight: FontWeight.bold)),");

// Blueprint Desc
code = code.replace("style: TextStyle(\n                fontSize: 11,\n                color: Theme.of(context).brightness == Brightness.dark\n                    ? Colors.white60\n                    : Colors.grey.shade700),", 
                    "style: TextStyle(\n                fontSize: 12,\n                color: Theme.of(context).brightness == Brightness.dark\n                    ? Colors.white60\n                    : Colors.grey.shade700),");

fs.writeFileSync('lib/main.dart', code);
console.log("Font sizes increased");

const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf8');

// XM Banner Title
code = code.replace("fontSize: 14,\n                          fontWeight: FontWeight.bold)),", "fontSize: 16,\n                          fontWeight: FontWeight.bold)),");
// XM Banner Desc
code = code.replace("style: TextStyle(color: Colors.white70, fontSize: 12)),", "style: TextStyle(color: Colors.white70, fontSize: 13.5)),");

// Mantra Card Title
code = code.replace("fontSize: 14,\n                        fontWeight: FontWeight.bold,\n                        color: Theme.of(context).brightness == Brightness.dark", 
                    "fontSize: 16,\n                        fontWeight: FontWeight.bold,\n                        color: Theme.of(context).brightness == Brightness.dark");

// Mantra Line
code = code.replace("fontSize: 13,\n              height: 1.4,\n              color: Theme.of(context).brightness == Brightness.dark", 
                    "fontSize: 15,\n              height: 1.5,\n              color: Theme.of(context).brightness == Brightness.dark");

// Blueprint Title
code = code.replace("TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),", "TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),");

// Blueprint Desc
code = code.replace("style: TextStyle(\n                fontSize: 12,\n                color: Theme.of(context).brightness == Brightness.dark", 
                    "style: TextStyle(\n                fontSize: 14,\n                color: Theme.of(context).brightness == Brightness.dark");

fs.writeFileSync('lib/main.dart', code);
console.log("Font sizes increased globally");

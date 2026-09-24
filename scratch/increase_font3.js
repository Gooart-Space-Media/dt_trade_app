const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf8');

code = code.replace(/fontSize:\s*13,[\s\S]*?fontWeight:\s*FontWeight\.bold\)\),/g, "fontSize: 15,\n                          fontWeight: FontWeight.bold)),");
code = code.replace(/style:\s*TextStyle\(color:\s*Colors\.white70,\s*fontSize:\s*11\)\),/g, "style: TextStyle(color: Colors.white70, fontSize: 13)),");

code = code.replace(/fontSize:\s*13,[\s\S]*?fontWeight:\s*FontWeight\.bold,[\s\S]*?color:\s*Theme\.of\(context\)\.brightness\s*==\s*Brightness\.dark/g, 
                    "fontSize: 15,\n                        fontWeight: FontWeight.bold,\n                        color: Theme.of(context).brightness == Brightness.dark");

code = code.replace(/fontSize:\s*11\.5,[\s\S]*?height:\s*1\.4,[\s\S]*?color:\s*Theme\.of\(context\)\.brightness\s*==\s*Brightness\.dark/g, 
                    "fontSize: 14,\n              height: 1.5,\n              color: Theme.of(context).brightness == Brightness.dark");

code = code.replace(/TextStyle\(fontSize:\s*14,\s*fontWeight:\s*FontWeight\.bold\)\),/g, "TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),");

code = code.replace(/fontSize:\s*10,[\s\S]*?color:\s*Color\(0xFF166534\),[\s\S]*?fontWeight:\s*FontWeight\.bold\)\),/g, 
                    "fontSize: 12,\n                        color: Color(0xFF166534),\n                        fontWeight: FontWeight.bold)),");

code = code.replace(/style:\s*TextStyle\([\s\S]*?fontSize:\s*11,[\s\S]*?color:\s*Theme\.of\(context\)\.brightness\s*==\s*Brightness\.dark/g, 
                    "style: TextStyle(\n                fontSize: 13,\n                color: Theme.of(context).brightness == Brightness.dark");

fs.writeFileSync('lib/main.dart', code);
console.log("Font sizes increased properly");

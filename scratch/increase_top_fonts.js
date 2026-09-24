const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf8');

// Replace status font 12 -> 13
code = code.replace(/Text\(session\['status'\] as String,[\s\S]*?fontSize:\s*12,/g, "Text(session['status'] as String,\n                              style: TextStyle(\n                                  fontSize: 13,");

// Replace countdown font 9 -> 11
code = code.replace(/child:\s*Text\(\n\s*session\['countdown'\] as String,[\s\S]*?fontSize:\s*9,/g, "child: Text(\n                              session['countdown'] as String,\n                              style: TextStyle(\n                                  fontSize: 11,");

// Replace desc font (which is probably 10) -> 12
code = code.replace(/child:\s*Text\(session\['desc'\] as String,[\s\S]*?fontSize:\s*10,/g, "child: Text(session['desc'] as String,\n                                    style: TextStyle(\n                                        fontSize: 12,");
code = code.replace(/Text\(session\['desc'\] as String,[\s\S]*?fontSize:\s*10,/g, "Text(session['desc'] as String,\n                                      style: TextStyle(\n                                          fontSize: 12,");

fs.writeFileSync('lib/main.dart', code);
console.log("Replaced fonts");

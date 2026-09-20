const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8').replace(/\r\n/g, '\n');

const oldRow1 = "(p) => setState(() { s1 = p; s2 = null; s3 = null; }), (d) => setState(() => dir1 = d)";
const newRow1 = "(p) { setState(() { s1 = p; s2 = null; s3 = null; }); _saveState('ol_s1', p); _saveState('ol_s2', null); _saveState('ol_s3', null); }, (d) { setState(() => dir1 = d); _saveState('ol_d1', d); }";

const oldRow2 = "(p) => setState(() { s2 = p; s3 = null; }), (d) => setState(() => dir2 = d)";
const newRow2 = "(p) { setState(() { s2 = p; s3 = null; }); _saveState('ol_s2', p); _saveState('ol_s3', null); }, (d) { setState(() => dir2 = d); _saveState('ol_d2', d); }";

const oldRow3 = "(p) => setState(() => s3 = p), (d) => setState(() => dir3 = d)";
const newRow3 = "(p) { setState(() => s3 = p); _saveState('ol_s3', p); }, (d) { setState(() => dir3 = d); _saveState('ol_d3', d); }";

code = code.split(oldRow1).join(newRow1);
code = code.split(oldRow2).join(newRow2);
code = code.split(oldRow3).join(newRow3);

const oldChecklist = "setState(() => checklist[index] = !checklist[index]);";
const newChecklist = "setState(() => checklist[index] = !checklist[index]); _saveState('ol_chk_${index}', checklist[index] ? 'true' : 'false');";
code = code.split(oldChecklist).join(newChecklist);

const oldLoad = "      dir3 = prefs.getString('ol_d3') ?? '多';\n    });";
const newLoad = "      dir3 = prefs.getString('ol_d3') ?? '多';\n      for(int i=0; i<4; i++) { checklist[i] = prefs.getString('ol_chk_${i}') == 'true'; }\n    });";
code = code.split(oldLoad).join(newLoad);

fs.writeFileSync('lib/main.dart', code);
console.log('Added SharedPreferences save logic!');

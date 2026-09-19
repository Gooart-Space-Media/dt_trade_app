const fs = require('fs');

const path = 'lib/main.dart';
let code = fs.readFileSync(path, 'utf-8');

// We have "\$\${" in the file right now.
// We want "\$\${" to become "\$${"
// In javascript string literal:
// "\\$\\$\\{" is "\$\${"
// "\\$\\$\\{" -> "\\$\\$\\{" is wrong.
// We want: backslash, dollar, dollar, brace
// to become: backslash, dollar, brace

code = code.split('\\$\\${').join('\\$${');
code = code.split('\\${').join('\\$${'); // just in case some \${ remain

fs.writeFileSync(path, code);
console.log('Fixed syntax in new path with Node!');

const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

const regex = /                Expanded\(\s*flex: 5,\s*child: SingleChildScrollView\(\s*child: Column\(\s*crossAxisAlignment: CrossAxisAlignment\.stretch,\s*children: leftChildren,\s*\),\s*\),\s*\),/g;

const replace = `                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: leftChildren,
                  ),
                ),`;

code = code.replace(regex, replace);
fs.writeFileSync('lib/main.dart', code);
console.log('Done!');

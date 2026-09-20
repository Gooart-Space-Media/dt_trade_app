const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8').replace(/\r\n/g, '\n');

// 1. Remove the empty '打开手数对照表' button at the top
const topBtnRegex = /            TextButton\.icon\(\n              onPressed: \(\)\{\},\n              icon: const Icon\(Icons\.bar_chart, size: 14, color: Colors\.teal\),\n              label: const Text\('打开手数对照表', style: TextStyle\(fontSize: 12, color: Colors\.teal\)\),\n            \),/g;
code = code.replace(topBtnRegex, '');

// 2. Remove the first duplicate '外汇点值' row
const redundantRowRegex = /        Row\(\n          mainAxisAlignment: MainAxisAlignment\.spaceBetween,\n          children: \[\n            Text\(isMicroMode \? '外汇点值: 0\.01手 = \\\$0\.001\/Pip \(Micro\)' : '外汇点值: 0\.01手 = \\\$0\.10\/Pip', style: TextStyle\(fontSize: 11, color: Colors\.grey\)\),\n            Row\(\n              children: \[\n                Icon\(Icons\.business_center, size: 12, color: Colors\.grey\),\n                SizedBox\(width: 4\),\n                Text\(isMicroMode \? '微型账户点值' : '标准账户点值', style: TextStyle\(fontSize: 11, color: Colors\.grey\)\),\n              \],\n            \)\n          \],\n        \),\n\n        const SizedBox\(height: 12\),\n/g;

code = code.replace(redundantRowRegex, '');

fs.writeFileSync('lib/main.dart', code);
console.log('Removed redundant UI elements!');

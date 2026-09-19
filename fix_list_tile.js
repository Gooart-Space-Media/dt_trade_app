const fs = require('fs');
const path = 'lib/main.dart';
let code = fs.readFileSync(path, 'utf-8');

const oldCode = `      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
        ),
        child: SwitchListTile(`;

const newCode = `      Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: SwitchListTile(`;

code = code.split(oldCode).join(newCode);

// There is also another one:
const oldCode2 = `      Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
        ),
        child: SwitchListTile(`;

const newCode2 = `      Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: SwitchListTile(`;

code = code.split(oldCode2).join(newCode2);

fs.writeFileSync(path, code);
console.log('Fixed ListTile assert!');

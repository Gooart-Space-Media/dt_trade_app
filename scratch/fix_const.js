const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf8');

// 1373: const SnackBar -> SnackBar
code = code.replace("const SnackBar(content: Text(AppLocalizations.of(context)!.msgOpeningXM))", "SnackBar(content: Text(AppLocalizations.of(context)!.msgOpeningXM))");

// 1410: const Expanded(child: Column... -> Expanded(child: Column...
code = code.replace("const Expanded(\n              child: Column(\n                crossAxisAlignment: CrossAxisAlignment.start,\n                children: [\n                  Text(AppLocalizations.of(context)!.titleXMBanner", 
                    "Expanded(\n              child: Column(\n                crossAxisAlignment: CrossAxisAlignment.start,\n                children: [\n                  Text(AppLocalizations.of(context)!.titleXMBanner");

// 1521: const Expanded( child: Text(AppLocalizations.of(context)!.titleBlueprint
code = code.replace("const Expanded(\n                child: Text(AppLocalizations.of(context)!.titleBlueprint", 
                    "Expanded(\n                child: Text(AppLocalizations.of(context)!.titleBlueprint");

// 1531: const Text(AppLocalizations.of(context)!.tagMultiK
code = code.replace("const Text(AppLocalizations.of(context)!.tagMultiK", "Text(AppLocalizations.of(context)!.tagMultiK");

fs.writeFileSync('lib/main.dart', code);
console.log("Fixed const errors");

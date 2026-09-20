const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// Inside _OverlapCheckerPageState build method
// Replace ListView children with a LayoutBuilder or just use isDesktop

const buildMethodRegex = /Widget build\(BuildContext context\) \{[\s\S]*?final allPairs = \[\.\.\.corePairs, \.\.\.minorPairs, \.\.\.observedPairs\];\s*bool isComplete = \(s1 != null && s2 != null && s3 != null\);\s*final audit = _auditCorrelation\(\);[\s\S]*?return ListView\([\s\S]*?padding: const EdgeInsets\.all\(10\),[\s\S]*?children: \[([\s\S]*?)\];\s*\}/;

// We will write a more precise replacement using AST or simple string replacement.
// Let's just create a new `build` method and replace the old one.

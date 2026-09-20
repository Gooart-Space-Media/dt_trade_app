const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

const targetStr = `        _buildDropdownRow('交易 1 (首选主线)', s1, dir1, allPairs, [], (p) => setState(() { s1 = p; s2 = null; s3 = null; }), (d) => setState(() => dir1 = d)),
        const SizedBox(height: 10),
        _buildDropdownRow('交易 2 (独立隔离)', s2, dir2, allPairs, [s1], (p) => setState(() { s2 = p; s3 = null; }), (d) => setState(() => dir2 = d)),
        const SizedBox(height: 10),
        _buildDropdownRow('交易 3 (独立隔离)', s3, dir3, allPairs, [s1, s2], (p) => setState(() => s3 = p), (d) => setState(() => dir3 = d)),`;

const replaceStr = `        isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildDropdownRow('交易 1 (首选主线)', s1, dir1, allPairs, [], (p) => setState(() { s1 = p; s2 = null; s3 = null; }), (d) => setState(() => dir1 = d))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDropdownRow('交易 2 (独立隔离)', s2, dir2, allPairs, [s1], (p) => setState(() { s2 = p; s3 = null; }), (d) => setState(() => dir2 = d))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDropdownRow('交易 3 (独立隔离)', s3, dir3, allPairs, [s1, s2], (p) => setState(() => s3 = p), (d) => setState(() => dir3 = d))),
                ],
              )
            : Column(
                children: [
                  _buildDropdownRow('交易 1 (首选主线)', s1, dir1, allPairs, [], (p) => setState(() { s1 = p; s2 = null; s3 = null; }), (d) => setState(() => dir1 = d)),
                  const SizedBox(height: 10),
                  _buildDropdownRow('交易 2 (独立隔离)', s2, dir2, allPairs, [s1], (p) => setState(() { s2 = p; s3 = null; }), (d) => setState(() => dir2 = d)),
                  const SizedBox(height: 10),
                  _buildDropdownRow('交易 3 (独立隔离)', s3, dir3, allPairs, [s1, s2], (p) => setState(() => s3 = p), (d) => setState(() => dir3 = d)),
                ],
              ),`;

if (code.includes(targetStr)) {
  code = code.replace(targetStr, replaceStr);
  code = code.replace(/constraints: const BoxConstraints\(maxWidth: 750\),/g, 'constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : 750),');
  
  const buildStart = /Widget build\(BuildContext context\) \{[\s\S]*?final allPairs = \[\.\.\.corePairs, \.\.\.minorPairs, \.\.\.observedPairs\];/;
  const buildReplace = 'Widget build(BuildContext context) {\n    bool isDesktop = MediaQuery.of(context).size.width > 800;\n    final allPairs = [...corePairs, ...minorPairs, ...observedPairs];';
  code = code.replace(buildStart, buildReplace);
  
  fs.writeFileSync('lib/main.dart', code);
  console.log('Replaced successfully!');
} else {
  console.log('Target string not found!');
}

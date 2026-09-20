const fs = require('fs');

const filepath = 'C:\\Projects\\dt_trade_app\\scratch\\tp_calc_build.dart';
const outpath = 'C:\\Projects\\dt_trade_app\\scratch\\tp_calc_new_build.dart';

// Read and normalize newlines
let content = fs.readFileSync(filepath, 'utf8').replace(/\r\n/g, '\n');

let build_start = content.indexOf('  Widget build(BuildContext context) {');
if (build_start === -1) {
    build_start = content.indexOf('Widget build(BuildContext context) {');
}

const listview_start = content.indexOf('    return ListView(', build_start);
const header = content.substring(build_start, listview_start);
const listview_content = content.substring(listview_start);

const children_start_str = '      children: [\n';
const children_start_idx = listview_content.indexOf(children_start_str) + children_start_str.length;

const listview_end_match = listview_content.lastIndexOf('      ],\n    );');
if (listview_end_match === -1) {
    console.log('Could not find listview end');
    process.exit(1);
}

const children_text = listview_content.substring(children_start_idx, listview_end_match);

const split_marker = '        if (hasData) ...[';
const split_idx = children_text.indexOf(split_marker);
if (split_idx === -1) {
    console.log('Could not find split marker');
    process.exit(1);
}

let left_text = children_text.substring(0, split_idx);
const right_text = children_text.substring(split_idx);

// Remove toggle 1
const toggle1_start = left_text.indexOf('        // 双轨/单轨切换\n');
if (toggle1_start === -1) {
    console.log('Could not find toggle1 start');
    process.exit(1);
}
const toggle1_end = left_text.indexOf('        // 模式切换：突破挂单 vs 黄金口袋 Fib\n');
if (toggle1_end === -1) {
    console.log('Could not find toggle1 end');
    process.exit(1);
}
left_text = left_text.substring(0, toggle1_start) + left_text.substring(toggle1_end);

// Remove toggle 2
const toggle2_start = left_text.indexOf('        // 模式切换：突破挂单 vs 黄金口袋 Fib\n');
if (toggle2_start === -1) {
    console.log('Could not find toggle2 start');
    process.exit(1);
}
const toggle2_end = left_text.indexOf('        Row(\n          mainAxisAlignment: MainAxisAlignment.spaceBetween,\n          children: [\n            ToggleButtons(');
if (toggle2_end === -1) {
    console.log('Could not find toggle2 end');
    process.exit(1);
}

left_text = left_text.substring(0, toggle2_start) + left_text.substring(toggle2_end);

const new_build = header + `    final leftChildren = <Widget>[
` + left_text + `    ];

    final rightChildren = <Widget>[
` + right_text + `    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: leftChildren,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: rightChildren,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(10),
          children: [
            ...leftChildren,
            ...rightChildren,
          ],
        );
      },
    );
  }`;

fs.writeFileSync(outpath, new_build, 'utf8');
console.log('Done!');

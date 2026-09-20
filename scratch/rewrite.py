import os
import sys

filepath = r'C:\Projects\dt_trade_app\scratch\tp_calc_build.dart'
outpath = r'C:\Projects\dt_trade_app\scratch\tp_calc_new_build.dart'

with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

build_start = content.find('  Widget build(BuildContext context) {')
if build_start == -1:
    build_start = content.find('Widget build(BuildContext context) {')

listview_start = content.find('    return ListView(', build_start)
header = content[build_start:listview_start]
listview_content = content[listview_start:]

children_start_str = '      children: [\n'
children_start_idx = listview_content.find(children_start_str) + len(children_start_str)

listview_end_match = listview_content.rfind('      ],\n    );')
if listview_end_match == -1:
    print('Could not find listview end')
    sys.exit(1)

children_text = listview_content[children_start_idx:listview_end_match]

split_marker = '        if (hasData) ...['
split_idx = children_text.find(split_marker)
if split_idx == -1:
    print('Could not find split marker')
    sys.exit(1)
left_text = children_text[:split_idx]
right_text = children_text[split_idx:]

# Remove toggle 1
toggle1_start = left_text.find('        // 双轨/单轨切换\n')
if toggle1_start == -1:
    print('Could not find toggle1 start')
    sys.exit(1)
toggle1_end = left_text.find('        // 模式切换：突破挂单 vs 黄金口袋 Fib\n')
if toggle1_end == -1:
    print('Could not find toggle1 end')
    sys.exit(1)
left_text = left_text[:toggle1_start] + left_text[toggle1_end:]

# Remove toggle 2
toggle2_start = left_text.find('        // 模式切换：突破挂单 vs 黄金口袋 Fib\n')
if toggle2_start == -1:
    print('Could not find toggle2 start')
    sys.exit(1)
toggle2_end = left_text.find('        Row(\n          mainAxisAlignment: MainAxisAlignment.spaceBetween,\n          children: [\n            ToggleButtons(')
if toggle2_end == -1:
    print('Could not find toggle2 end')
    sys.exit(1)

left_text = left_text[:toggle2_start] + left_text[toggle2_end:]

new_build = header + '''    final leftChildren = <Widget>[
''' + left_text + '''    ];

    final rightChildren = <Widget>[
''' + right_text + '''    ];

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
  }
'''

with open(outpath, 'w', encoding='utf-8') as f:
    f.write(new_build)
print('Done!')

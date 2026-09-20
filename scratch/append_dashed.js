const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

const dashedLineClass = `
class _DashedLine extends StatelessWidget {
  final Color color;
  const _DashedLine({required this.color});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
`;

code = code + dashedLineClass;
fs.writeFileSync('lib/main.dart', code);
console.log('Appended _DashedLine properly');

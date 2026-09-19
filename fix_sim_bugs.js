const fs = require('fs');

const path = 'lib/main.dart';
let code = fs.readFileSync(path, 'utf-8');

// Fix illegal imports injected by the subagent
code = code.replace(/﻿import 'dart:math';\r?\n/g, '');
code = code.replace(/import 'dart:math';\r?\n/g, '');
code = code.replace(/import 'package:flutter\/material.dart';\r?\n/g, '');
code = code.replace(/import 'package:flutter\/services.dart';\r?\n/g, '');
code = code.replace(/import 'package:shared_preferences\/shared_preferences.dart';\r?\n/g, '');
code = code.replace(/import 'package:fl_chart\/fl_chart.dart';\r?\n/g, '');

// Fix unterminated string
code = code.replace(/textStr = '\\\\';/g, "textStr = '-';");

fs.writeFileSync(path, code);
console.log('Fixed imports and syntax!');

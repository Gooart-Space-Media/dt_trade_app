const fs = require('fs');
const content = fs.readFileSync('C:\\Users\\czx01\\.gemini\\antigravity\\brain\\e910d151-e974-48fb-b453-b5e3c6b8a2c3\\.system_generated\\steps\\3629\\output.txt', 'utf-8');
const urls = content.match(/https:\/\/[^\s\"\'\}]+/g);
if(urls) {
  Array.from(new Set(urls)).forEach(u => console.log(u));
} else {
  console.log('No URLs found');
}

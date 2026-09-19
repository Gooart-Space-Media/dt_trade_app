import os

path = r"C:\Projects\dt_trade_app\lib\main.dart"
with open(path, "r", encoding="utf-8") as f:
    code = f.read()

# Replace \$\${ with \$${
code = code.replace(r"\$\${", r"\$${")

with open(path, "w", encoding="utf-8") as f:
    f.write(code)

print("Fixed syntax in new path!")

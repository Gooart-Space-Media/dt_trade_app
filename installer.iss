; Inno Setup Script for DT Trade App
[Setup]
AppName=双轨风控大师 Pro
AppVersion=1.0.0
AppPublisher=Gooart Space Media
AppPublisherURL=https://github.com/Gooart-Space-Media/dt_trade_app
DefaultDirName={autopf}\DT Trade App
DefaultGroupName=DT Trade App
OutputDir=.
OutputBaseFilename=dt_trade_app_setup
Compression=lzma2
SolidCompression=yes
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\dt_trade_app.exe
WizardStyle=modern
PrivilegesRequired=lowest

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\双轨风控大师 Pro"; Filename: "{app}\dt_trade_app.exe"
Name: "{group}\卸载 双轨风控大师 Pro"; Filename: "{uninstallexe}"
Name: "{autodesktop}\双轨风控大师 Pro"; Filename: "{app}\dt_trade_app.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "附加选项:"

[Run]
Filename: "{app}\dt_trade_app.exe"; Description: "立即启动 双轨风控大师 Pro"; Flags: nowait postinstall skipifsilent

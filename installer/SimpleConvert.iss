#define MyAppName "Jaiho SimpleConvert"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "Jaiho Digital"

[Setup]
AppId={{4E13B80A-5B4B-4C69-93E5-91F6E3D8A702}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\Jaiho Digital\SimpleConvert
DefaultGroupName=Jaiho Digital\SimpleConvert
OutputDir=..\dist
OutputBaseFilename=SimpleConvert-Setup-0.1.0
SetupIconFile=..\apps\SimpleConvert\assets\SimpleConvert.ico
UninstallDisplayIcon={app}\SimpleConvert.exe
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"

[Files]
Source: "..\dist\SimpleConvert\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\SimpleConvert"; Filename: "{app}\SimpleConvert.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\SimpleConvert"; Filename: "{app}\SimpleConvert.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\SimpleConvert.exe"; Description: "Launch SimpleConvert"; Flags: postinstall nowait skipifsilent

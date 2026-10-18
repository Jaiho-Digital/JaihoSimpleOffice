#define MyAppName "Jaiho SimpleCalendar"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "Jaiho Digital"

[Setup]
AppId={{9A64C5D2-6B71-4D91-A7B0-3D2F8E61C450}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\Jaiho Digital\SimpleCalendar
DefaultGroupName=Jaiho Digital\SimpleCalendar
OutputDir=..\dist
OutputBaseFilename=SimpleCalendar-Setup-0.1.0
SetupIconFile=..\apps\SimpleCalendar\assets\SimpleCalendar.ico
UninstallDisplayIcon={app}\SimpleCalendar.exe
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
Source: "..\dist\SimpleCalendar\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\SimpleCalendar"; Filename: "{app}\SimpleCalendar.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\SimpleCalendar"; Filename: "{app}\SimpleCalendar.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\SimpleCalendar.exe"; Description: "Launch SimpleCalendar"; Flags: postinstall nowait skipifsilent

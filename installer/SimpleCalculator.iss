#define MyAppName "SimpleCalculator"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "Jaiho Digital"
#define MyAppURL "https://jaiho-digital.onrender.com/j-simple-office.html"

[Setup]
AppId={{B9D8C2F1-75A4-4B63-9E21-8A40D2C6F571}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\Jaiho Digital\SimpleCalculator
DefaultGroupName=SimpleCalculator
DisableProgramGroupPage=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
WizardStyle=modern
SetupIconFile=..\apps\SimpleCalculator\assets\SimpleCalculator.ico
UninstallDisplayIcon={app}\SimpleCalculator.exe
OutputDir=..\dist\installer
OutputBaseFilename=SimpleCalculator-0.1.0-Setup
Compression=lzma2
SolidCompression=yes
CloseApplications=yes
VersionInfoVersion=0.1.0.0
VersionInfoCompany=Jaiho Digital
VersionInfoDescription=SimpleCalculator Installer
Uninstallable=yes

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[Files]
Source: "..\dist\SimpleCalculator\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\SimpleCalculator"; Filename: "{app}\SimpleCalculator.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\SimpleCalculator"; Filename: "{app}\SimpleCalculator.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\SimpleCalculator.exe"; Description: "Launch SimpleCalculator"; WorkingDir: "{app}"; Flags: postinstall nowait skipifsilent

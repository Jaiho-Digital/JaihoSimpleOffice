
#define MyAppName "SimpleNotes"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "Jaiho Digital"
#define MyAppURL "https://jaiho-digital.onrender.com/j-simple-office.html"

[Setup]
AppId={{9C6A2B81-4A79-4A53-8D41-8E8BDF9A1037}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={localappdata}\Programs\Jaiho Digital\SimpleNotes
DefaultGroupName=SimpleNotes
DisableProgramGroupPage=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=lowest
WizardStyle=modern
SetupIconFile=..\apps\SimpleNotes\assets\SimpleNotes.ico
UninstallDisplayIcon={app}\SimpleNotes.exe
OutputDir=..\dist\installer
OutputBaseFilename=SimpleNotes-0.1.0-Setup
Compression=lzma2
SolidCompression=yes
CloseApplications=yes
VersionInfoVersion=0.1.0.0
VersionInfoCompany=Jaiho Digital
VersionInfoDescription=SimpleNotes Installer
Uninstallable=yes

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[Files]
Source: "..\dist\SimpleNotes\*"; DestDir: "{app}"; Excludes: "Launch-SimpleNotes.bat"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\SimpleNotes"; Filename: "{app}\SimpleNotes.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\SimpleNotes"; Filename: "{app}\SimpleNotes.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\SimpleNotes.exe"; Description: "Launch SimpleNotes"; WorkingDir: "{app}"; Flags: postinstall nowait skipifsilent

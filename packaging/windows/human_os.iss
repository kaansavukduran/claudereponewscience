; Inno Setup script for the Human OS Windows installer (development build).
; Built on a Windows host by .github/workflows/windows-exe.yml; never built here.
; The app keeps its data under %LOCALAPPDATA%, outside the install folder, so
; uninstalling does not delete a person's records.
#define AppName "Human OS"
#ifndef AppVersion
  #define AppVersion "0.1.0"
#endif

[Setup]
AppId={{6B1F6E9A-4C1B-4B77-9C0E-1A2B3C4D5E6F}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=Human OS
DefaultDirName={autopf}\Human OS
DefaultGroupName=Human OS
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=..\..\dist
OutputBaseFilename=Human-OS-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\human_health_os.exe

[Files]
Source: "..\..\human_health_os\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{autoprograms}\Human OS"; Filename: "{app}\human_health_os.exe"
Name: "{autodesktop}\Human OS"; Filename: "{app}\human_health_os.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Shortcuts:"

[Run]
Filename: "{app}\human_health_os.exe"; Description: "Open Human OS"; Flags: nowait postinstall skipifsilent

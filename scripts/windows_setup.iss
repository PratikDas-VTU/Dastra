; Dastra Professional Windows Installer Script
; Designed for Inno Setup 6+
; Supports both per-user and machine-wide installations.

#ifndef MyAppName
#define MyAppName "Dastra"
#endif

#ifndef MyAppVersion
#define MyAppVersion "1.0.0"
#endif

#ifndef MyAppOutputBaseFilename
#define MyAppOutputBaseFilename "DastraSetup"
#endif

#define MyAppPublisher "Pratik Das"
#define MyAppURL "https://github.com/PratikDas-VTU/Dastra"
#define MyAppExeName "dastra.exe"
#define MyAppId "{{9A2A622B-DFF2-4E89-9317-B9026AD9EDA9}"
#define MyBuildDir "..\build\windows\x64\runner\Release"
#define MyLicenseFile "..\LICENSE"
#define MyIconFile "..\windows\runner\resources\app_icon.ico"

[Setup]
; App Identity
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
AppCopyright=Copyright (C) 2026 {#MyAppPublisher}

; Dual-Mode Installation (Per-user default, allows Admin override)
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}

; Output configuration
OutputDir=..\releases
OutputBaseFilename={#MyAppOutputBaseFilename}
SetupIconFile={#MyIconFile}

; Compression & Modernization
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

; Metadata and UX
LicenseFile={#MyLicenseFile}
SetupLogging=yes
UninstallDisplayIcon={app}\{#MyAppExeName}
DisableProgramGroupPage=yes
CloseApplications=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Main Executable and Flutter runtime
Source: "{#MyBuildDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
; Include Flutter engine, plugins, and VC++ redistributable DLLs if present
Source: "{#MyBuildDir}\*.dll"; DestDir: "{app}"; Flags: ignoreversion
; Include the data folder containing the compiled code and assets
Source: "{#MyBuildDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

#ifndef MyAppDataFolder
#define MyAppDataFolder "Dastra"
#endif

[Code]
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  LocalAppDataDir: string;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    LocalAppDataDir := ExpandConstant('{localappdata}\{#MyAppDataFolder}');
    
    if DirExists(LocalAppDataDir) then
    begin
      if MsgBox('Do you also want to remove your Dastra application data and settings?', mbConfirmation, MB_YESNO) = idYes then
      begin
        DelTree(LocalAppDataDir, True, True, True);
      end;
    end;
  end;
end;

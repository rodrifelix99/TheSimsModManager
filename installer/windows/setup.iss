; Inno Setup script for The Sims Mod Manager.
; Built in CI with: ISCC.exe /DAppVersion=x.y.z installer\windows\setup.iss
; (run from the repository root, after `flutter build windows --release`
; and after copying the VC++ runtime DLLs into the Release folder).

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

#define AppName "The Sims Mod Manager"
#define AppExeName "sims_mod_manager.exe"
#define BuildDir "..\..\build\windows\x64\runner\Release"

[Setup]
; Never change this AppId; it is how Windows recognises upgrades of the same app.
AppId={{E7B34D2A-6C1F-4B4A-9D6E-2F8A51C90B37}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=Felix
AppPublisherURL=https://github.com/rodrifelix99/TheSimsModManager
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
UninstallDisplayIcon={app}\{#AppExeName}
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
OutputDir=..\..\dist
OutputBaseFilename=TheSimsModManager-{#AppVersion}-windows-setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Per-user install by default (no admin prompt); the dialog lets users
; choose an all-users install if they prefer.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent

[Code]
// Uninstall analytics: the app leaves its anonymous PostHog id in
// %APPDATA%\TheSimsModManager\telemetry_id while the user has analytics
// enabled (see lib/src/services/analytics.dart). If the file exists at
// uninstall time, ping PostHog once so uninstalls are measurable, then
// clean the marker up. Best-effort and silent: no file (opted out) or no
// curl means no ping, and the uninstall never waits more than ~10s.
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  MarkerDir, MarkerFile, BodyFile: String;
  // AnsiString, not String: LoadStringFromFile/SaveStringToFile take
  // AnsiString in Unicode Inno Setup, and var params must match exactly.
  DistinctId, Body: AnsiString;
  ResultCode: Integer;
begin
  if CurUninstallStep <> usPostUninstall then
    exit;
  MarkerDir := ExpandConstant('{userappdata}') + '\TheSimsModManager';
  MarkerFile := MarkerDir + '\telemetry_id';
  if LoadStringFromFile(MarkerFile, DistinctId) then
  begin
    DistinctId := Trim(DistinctId);
    if (DistinctId <> '') and (Length(DistinctId) < 100) then
    begin
      Body := '{"api_key":"phc_zzqKjNq5hTkeHD8LmMSzdTvtoKzD29ojo7r9zeCuVznd",'
        + '"event":"app_uninstalled","distinct_id":"' + DistinctId + '",'
        + '"properties":{"$os":"Windows","app_version":"{#AppVersion}",'
        + '"$app_version":"{#AppVersion}","app_name":"TheSimsModManager"}}';
      // curl reads the JSON from a temp file: no shell-quoting battles.
      BodyFile := ExpandConstant('{tmp}') + '\uninstall_event.json';
      if SaveStringToFile(BodyFile, Body, False) then
        Exec(ExpandConstant('{sys}\curl.exe'),
          '-s -m 10 -H "Content-Type: application/json" --data "@' + BodyFile
            + '" https://eu.i.posthog.com/i/v0/e/',
          '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    end;
    DeleteFile(MarkerFile);
    RemoveDir(MarkerDir);
  end;
end;

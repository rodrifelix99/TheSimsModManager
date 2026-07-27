#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <string.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"
#include "app_links/app_links_plugin_c_api.h"

namespace {

// app_links exports exactly this as SendAppLinkToInstance(), but only from
// 7.2.0 on, and every version from 7.1.0 wants Flutter 3.44 - which
// release.yml cannot have while flutter/flutter#189183 keeps it pinned to
// 3.41.9. So the same walk lives here instead. Once that pin lifts, delete
// all of this, raise the app_links constraint in pubspec.yaml and call the
// plugin's own again.
//
// The window is matched on the executable behind it rather than on its
// title, which is what the plugin settled on too: a title is a display
// string, while a link registered for one copy of the app belongs to that
// copy and not to some other build of it that happens to be open.
bool SendAppLinkToRunningInstance() {
  struct Match {
    HWND window;
    wchar_t executable[MAX_PATH];
  };
  Match match = {};
  if (::GetModuleFileNameW(nullptr, match.executable, MAX_PATH) == 0) {
    return false;
  }

  ::EnumWindows(
      [](HWND window, LPARAM lparam) -> BOOL {
        auto *match = reinterpret_cast<Match *>(lparam);
        wchar_t class_name[64] = {};
        ::GetClassNameW(window, class_name, 64);
        if (_wcsicmp(class_name, L"FLUTTER_RUNNER_WIN32_WINDOW") != 0) {
          return TRUE;
        }
        DWORD process_id = 0;
        ::GetWindowThreadProcessId(window, &process_id);
        HANDLE process = ::OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION,
                                       FALSE, process_id);
        if (process == nullptr) {
          return TRUE;
        }
        wchar_t executable[MAX_PATH] = {};
        DWORD length = MAX_PATH;
        const BOOL named =
            ::QueryFullProcessImageNameW(process, 0, executable, &length);
        ::CloseHandle(process);
        if (named && _wcsicmp(executable, match->executable) == 0) {
          match->window = window;
          return FALSE;  // Found it; stop walking.
        }
        return TRUE;
      },
      reinterpret_cast<LPARAM>(&match));

  if (match.window == nullptr) {
    return false;
  }

  SendAppLink(match.window);

  // Back to wherever the user left it: a window they had maximized stays
  // maximized, and a minimized one comes back up rather than being
  // restored to some size it never had.
  WINDOWPLACEMENT placement = {sizeof(WINDOWPLACEMENT)};
  ::GetWindowPlacement(match.window, &placement);
  switch (placement.showCmd) {
    case SW_SHOWMAXIMIZED:
      ::ShowWindow(match.window, SW_SHOWMAXIMIZED);
      break;
    case SW_SHOWMINIMIZED:
      ::ShowWindow(match.window, SW_RESTORE);
      break;
    default:
      ::ShowWindow(match.window, SW_NORMAL);
      break;
  }
  ::SetForegroundWindow(match.window);
  return true;
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // A simsmodmanager:// link clicked while the app is already open starts
  // a second copy of it. Hand the address to the first one, bring that
  // window forward, and go away again.
  if (SendAppLinkToRunningInstance()) {
    return EXIT_SUCCESS;
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 824);
  if (!window.Create(L"Sims Mod Manager", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}

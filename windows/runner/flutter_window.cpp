#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

namespace {

// Windows refuses messages sent from a lower integrity level to a higher
// one (UIPI). Explorer runs at medium, an elevated app at high, so when
// the app is started as administrator - which the games that keep their
// mods inside Program Files push people into - a drag from a folder
// window never reaches us and dropping files does nothing at all, with
// no error anywhere to explain it. desktop_drop's RegisterDragDrop is
// fine; the messages OLE drag and drop rides on are what get dropped.
//
// Letting those three through is the documented way out. It changes
// nothing when the app is not elevated (there is nothing to filter),
// so it is unconditional.
void AllowDropsFromLowerIntegrity(HWND window) {
  if (window == nullptr) {
    return;
  }
  ::ChangeWindowMessageFilterEx(window, WM_DROPFILES, MSGFLT_ALLOW, nullptr);
  ::ChangeWindowMessageFilterEx(window, WM_COPYDATA, MSGFLT_ALLOW, nullptr);
  // WM_COPYGLOBALDATA carries the dragged file names and has no name of
  // its own in the headers.
  ::ChangeWindowMessageFilterEx(window, 0x0049, MSGFLT_ALLOW, nullptr);
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  // Both windows: desktop_drop registers its drop target on the Flutter
  // view, which is a child of ours, and the filter is per window.
  AllowDropsFromLowerIntegrity(GetHandle());
  AllowDropsFromLowerIntegrity(flutter_controller_->view()->GetNativeWindow());

  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

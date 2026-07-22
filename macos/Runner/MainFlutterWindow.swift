import Cocoa
import FlutterMacOS
import flutter_acrylic

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let windowFrame = self.frame
    // flutter_acrylic: host Flutter inside its blurry container so the
    // NSVisualEffectView backdrop shows through transparent Flutter pixels.
    let blurryContainerViewController = BlurryContainerViewController()
    self.contentViewController = blurryContainerViewController
    self.setFrame(windowFrame, display: true)

    MainFlutterWindowManipulator.start(mainFlutterWindow: self)

    RegisterGeneratedPlugins(registry: blurryContainerViewController.flutterViewController)

    super.awakeFromNib()
  }
}

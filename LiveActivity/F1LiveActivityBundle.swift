import WidgetKit
import SwiftUI

/// Entry point for the Live Activity widget extension.
/// Required: Xcode needs a `@main` struct in each widget extension target.
@main
struct F1LiveActivityBundle: WidgetBundle {
    var body: some Widget {
        F1LiveActivity()
    }
}

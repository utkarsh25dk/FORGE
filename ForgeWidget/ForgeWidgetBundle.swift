import WidgetKit
import SwiftUI

@main
struct ForgeWidgetBundle: WidgetBundle {
    var body: some Widget {
        ForgeWidget()
        ForgeWaterWidget()
        LiveWorkoutActivityWidget()
    }
}

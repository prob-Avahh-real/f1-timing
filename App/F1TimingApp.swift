import SwiftUI

@main
struct F1TimingApp: App {
    @State private var dataSource: TimingDataSource = {
        #if DEBUG
        MockTimingDataSource()
        #else
        WebSocketTimingService()
        #endif
    }()

    @State private var viewModel: TimingViewModel?

    var body: some Scene {
        WindowGroup {
            ContentView(dataSource: dataSource)
                .onAppear {
                    viewModel = TimingViewModel(dataSource: dataSource)
                }
        }
    }
}

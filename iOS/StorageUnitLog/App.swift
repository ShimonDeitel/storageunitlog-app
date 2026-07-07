import SwiftUI

@main
struct StorageUnitLogApp: App {
    @StateObject private var store = Store()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(purchases)
                .tint(Theme.accent)
                .onChange(of: purchases.isPro) { _, newValue in
                    store.isPro = newValue
                }
        }
    }
}

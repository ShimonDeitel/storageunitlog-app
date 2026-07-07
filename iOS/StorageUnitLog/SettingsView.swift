import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    @AppStorage("storageunitlog_remindersEnabled") private var remindersEnabled = true
    @AppStorage("storageunitlog_showNotes") private var showNotes = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Enable Reminders", isOn: $remindersEnabled)
                        .accessibilityIdentifier("remindersToggle")
                    Toggle("Show Notes Field", isOn: $showNotes)
                        .accessibilityIdentifier("showNotesToggle")
                }

                Section("Subscription") {
                    if purchases.isPro {
                        Label("Pro Unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Theme.accent)
                    } else {
                        Button("Upgrade to Pro") {
                            store.presentPaywall = true
                        }
                        .accessibilityIdentifier("upgradeToProButton")
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("settingsRestoreButton")
                }

                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/storageunitlog-app/privacy.html")!)
                        .accessibilityIdentifier("privacyPolicyLink")
                    Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/storageunitlog-app/terms.html")!)
                        .accessibilityIdentifier("termsLink")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settingsDoneButton")
                }
            }
        }
    }
}

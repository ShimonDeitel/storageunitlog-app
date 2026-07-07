import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.accent)
                    .padding(.top, 32)

                Text("Storage Unit Log Pro")
                    .font(Theme.titleFont)

                Text("Unlimited boxes, photo-per-box, and full-text search across contents")
                    .font(Theme.bodyFont)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, 32)

                if let product = purchases.product {
                    Button {
                        Task { await purchases.purchase() }
                    } label: {
                        Text("Unlock for \(product.displayPrice)/month")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .accessibilityIdentifier("paywallPurchaseButton")
                    .padding(.horizontal, 24)
                } else {
                    ProgressView()
                }

                Button("Restore Purchases") {
                    Task { await purchases.restore() }
                }
                .accessibilityIdentifier("restorePurchasesButton")
                .font(.footnote)

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .accessibilityIdentifier("paywallCloseButton")
                }
            }
        }
    }
}

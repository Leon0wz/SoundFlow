import StoreKit

@Observable
@MainActor
final class StoreManager {
    var subscriptionStatus: AppSubscriptionStatus = .free
    var products: [Product] = []

    func loadProducts() async {
        do {
            let productIDs = [
                AppConstants.Subscription.monthlyProductID,
                AppConstants.Subscription.yearlyProductID,
                AppConstants.Subscription.lifetimeProductID
            ]
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try verification.payloadValue
            await transaction.finish()
            subscriptionStatus = .premium(expirationDate: transaction.expirationDate)
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
    }
}

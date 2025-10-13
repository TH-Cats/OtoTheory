//
//  ProManager.swift
//  OtoTheory
//
//  Phase 1: IAP & Pro feature management
//

import Foundation
import StoreKit
import Combine

/// Pro subscription manager using StoreKit 2
@MainActor
class ProManager: ObservableObject {
    static let shared = ProManager()
    
    // MARK: - Published Properties
    
    /// Whether the user has an active Pro subscription
    @Published var isProUser: Bool = false
    
    /// Available products from App Store
    @Published var products: [Product] = []
    
    /// Set of purchased product IDs
    @Published var purchasedProductIDs: Set<String> = []
    
    /// Loading state
    @Published var isLoading: Bool = false
    
    // MARK: - Product IDs
    
    /// Pro monthly subscription product ID
    /// NOTE: This must match the product ID configured in App Store Connect
    private let proSubscriptionID = "com.ototheory.pro.monthly"
    
    // MARK: - Transaction Listener
    
    private var transactionListener: Task<Void, Never>?
    
    // MARK: - Initialization
    
    private init() {
        // 🧪 DEBUG: Force Pro mode for testing (remove before production)
        #if DEBUG
        self.isProUser = true
        print("⚠️ DEBUG MODE: Pro features enabled for testing")
        #endif
        
        // Start transaction listener
        transactionListener = listenForTransactions()
        
        // Load products and check purchase status
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    // MARK: - Product Loading
    
    /// Load available products from App Store
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let loadedProducts = try await Product.products(for: [proSubscriptionID])
            self.products = loadedProducts
            
            #if DEBUG
            print("[ProManager] Loaded \(loadedProducts.count) products")
            for product in loadedProducts {
                print("  - \(product.id): \(product.displayName) (\(product.displayPrice))")
            }
            #endif
        } catch {
            print("[ProManager] Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase Status
    
    /// Update purchased products by checking current entitlements
    func updatePurchasedProducts() async {
        // 🧪 DEBUG: Skip updating Pro status (already forced to true)
        #if DEBUG
        if isProUser {
            print("[ProManager] Skipping Pro status update (DEBUG mode active)")
            return
        }
        #endif
        
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                print("[ProManager] Unverified transaction: \(result)")
                continue
            }
            
            // Check if the subscription is active
            if transaction.revocationDate == nil {
                purchasedIDs.insert(transaction.productID)
            }
            
            #if DEBUG
            print("[ProManager] Entitlement: \(transaction.productID)")
            #endif
        }
        
        self.purchasedProductIDs = purchasedIDs
        self.isProUser = purchasedIDs.contains(proSubscriptionID)
        
        #if DEBUG
        print("[ProManager] Pro status: \(isProUser)")
        #endif
    }
    
    // MARK: - Purchase
    
    /// Purchase a product
    func purchase(_ product: Product) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    // Transaction is verified, finalize it
                    await transaction.finish()
                    
                    // Update purchase status
                    await updatePurchasedProducts()
                    
                    // Track success
                    TelemetryService.shared.trackPurchaseSuccess(productId: product.id)
                    
                    #if DEBUG
                    print("[ProManager] Purchase successful: \(product.id)")
                    #endif
                    
                case .unverified(_, let error):
                    // Transaction failed verification
                    let errorMsg = "Transaction unverified: \(error)"
                    TelemetryService.shared.trackPurchaseFail(error: errorMsg)
                    throw PurchaseError.unverified
                }
                
            case .userCancelled:
                #if DEBUG
                print("[ProManager] Purchase cancelled by user")
                #endif
                throw PurchaseError.userCancelled
                
            case .pending:
                #if DEBUG
                print("[ProManager] Purchase pending")
                #endif
                throw PurchaseError.pending
                
            @unknown default:
                throw PurchaseError.unknown
            }
        } catch {
            let errorMsg = error.localizedDescription
            TelemetryService.shared.trackPurchaseFail(error: errorMsg)
            throw error
        }
    }
    
    // MARK: - Restore
    
    /// Restore previous purchases
    func restore() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            
            TelemetryService.shared.trackRestoreSuccess()
            
            #if DEBUG
            print("[ProManager] Restore successful")
            #endif
        } catch {
            let errorMsg = error.localizedDescription
            TelemetryService.shared.trackRestoreFail(error: errorMsg)
            throw error
        }
    }
    
    // MARK: - Transaction Listener
    
    /// Listen for transactions (e.g., purchases made on another device)
    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else {
                    continue
                }
                
                // Finish the transaction
                await transaction.finish()
                
                // Update purchase status on main actor
                await self?.updatePurchasedProducts()
            }
        }
    }
}

// MARK: - Errors

enum PurchaseError: LocalizedError {
    case unverified
    case userCancelled
    case pending
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .unverified:
            return "購入の検証に失敗しました"
        case .userCancelled:
            return "購入がキャンセルされました"
        case .pending:
            return "購入処理が保留中です"
        case .unknown:
            return "不明なエラーが発生しました"
        }
    }
}


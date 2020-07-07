import UIKit
import StoreKit

class IAPHelper: NSObject{
    let productIds = ["com.redfast.test.consumable"]
    let productsRequest: SKProductsRequest
    var products: [SKProduct]?
    static let shared = IAPHelper()
    
    private override init() {
        productsRequest = SKProductsRequest(productIdentifiers: Set(productIds))
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func getProducts() {
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func purchase(_ product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
}

extension IAPHelper: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        for p in products! {
          print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
}

extension IAPHelper: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                print("purchase successfully")
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .failed:
                print("failed purchase")
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .restored:
                print("restored purchase")
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .deferred:
                print("deferred purchase")
                break
            case .purchasing:
                print("purchasing purchase")
                break
            default:
                print("unknown purchase state")
                break
            }
        }
    }
}

//
//  FavoriteViewModel.swift
//  Shopify
//
//  Created by maha on 18/06/2024.
//

import Foundation

class FavoriteViewModel {
    private var favoriteProductTitles: Set<String> = []
    var lineItems: [LineItem] = [] {
        didSet {
            self.didUpdateLineItems?()
        }
    }
    
    var didUpdateLineItems: (() -> Void)?
    var displayedLineItems: [LineItem] {
         if lineItems.count > 1 {
             Constants.displayedLineItems = Array(lineItems.dropFirst())
             return Array(lineItems.dropFirst())
         } else {
             return []
         }
     }

    func fetchLineItems(draftOrderId: Int) {
        NetworkManager.fetchLineItemsInDraftOrder(draftOrderId: draftOrderId) { [weak self] lineItems in
            guard let self = self else { return }
            if let lineItems = lineItems {
                self.lineItems = lineItems
            } else {
                print("No line items found")
            }
        }
        for item in self.lineItems {
                print("Title: \(item.title ?? ""), Price: \(item.price ?? ""), Image: \(item.image ?? "")")
            }
        didUpdateLineItems?()
    }
   
    func removeProductFromDraftOrder(productTitle: String) {
         let draftOrderIDFavorite = Utilites.getDraftOrderIDFavorite() 
        
        NetworkManager.removeLineItemFromDraftOrder(draftOrderId: draftOrderIDFavorite, productTitle: productTitle) { statusCode in
            if statusCode == 200 {
                print("Product removed from draft order successfully")
                
            } else {
                print("Failed to remove product from draft order. Status code: \(statusCode)")
            }
        }
        didUpdateLineItems?()
    }
}


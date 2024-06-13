//
//  DraftOrder.swift
//  Shopify
//
//  Created by maha on 13/06/2024.
//

import Foundation
struct AllDrafts: Codable {
    var draftOrders: [DraftOrder]?

    enum CodingKeys: String, CodingKey {
        case draftOrders = "draft_orders"
    }
}
struct Drafts: Codable {
    var draftOrder: DraftOrder?

    enum CodingKeys: String, CodingKey {
        case draftOrder = "draft_order"
    }
}
class DraftOrder: Codable {
    var id: Int?
    var note: String?
    var email: String?
    var lineItems: [DraftOrderProduct]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case note
        case email
        case lineItems = "line_items"
    }
    
    init(id: Int?,note:String?,email:String?, lineItems: [DraftOrderProduct]?) {
        self.id = id
        self.note = note
        self.email = email
        self.lineItems = lineItems
    }
}
class DraftOrderProduct: Codable {
    var id: Int?
    var quantity: Int?
    var price: String?
    var title: String?
    var imageSrc: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case quantity
        case price
        case title
        case imageSrc = "sku"
    }
    
    init(id:Int?, quantity: Int?, price: String?, title: String?, imageSrc: String? = nil) {
        self.id = id
        self.quantity = quantity
        self.price = price
        self.title = title
        self.imageSrc = imageSrc
    }
}



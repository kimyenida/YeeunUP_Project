//
//  DefinedOrderBook.swift
//  YeeunUP
//
//  Created by 김예은 on 1/2/25.
//

enum OrderbookType {
    case ask // 매도
    case bid // 매수
}

struct DefinedOrderBook: Hashable {
    var timeStamp: Double?
    var code: String?
    var price: Double?
    var type: OrderbookType?
    
    var uniqueIdentifier: String {
        return "\(String(describing: code))-\(String(describing: price))-\(String(describing: timeStamp))"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueIdentifier)
    }
    
    static func == (lhs: DefinedOrderBook, rhs: DefinedOrderBook) -> Bool {
        return lhs.uniqueIdentifier == rhs.uniqueIdentifier
    }
    
}

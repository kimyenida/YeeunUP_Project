//
//  OrderBookAPIProcess.swift
//  YeeunUP
//
//  Created by 김예은 on 1/2/25.
//

import Foundation

final class OrderBookAPIProcess: OrderBookAPIServiceProtocol {
    let networking = NetworkRouter<OrderBookEndPoint>()
    
    func getOrderBook(markets: [String]) async throws -> [OrderBook] {
        try await networking.request(.orderBook(markets: markets))
    }
}

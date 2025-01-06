//
//  OrderBookAPIServiceProtocol.swift
//  YeeunUP
//
//  Created by 김예은 on 1/2/25.
//

protocol OrderBookAPIServiceProtocol {
    func getOrderBook(markets: [String]) async throws -> [OrderBook]
}

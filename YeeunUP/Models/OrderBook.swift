//
//  OrderBook.swift
//  YeeunUP
//
//  Created by 김예은 on 1/2/25.
//

// MARK: - WelcomeElement
struct OrderBook: Codable {
    let market: String
    let timestamp: Double
    let totalAskSize, totalBidSize: Double
    let orderbookUnits: [OrderbookUnit]
    let level: Double

    enum CodingKeys: String, CodingKey {
        case market, timestamp
        case totalAskSize = "total_ask_size"
        case totalBidSize = "total_bid_size"
        case orderbookUnits = "orderbook_units"
        case level
    }
}

// MARK: - OrderbookUnit
struct OrderbookUnit: Codable {
    let askPrice, bidPrice: Double
    let askSize, bidSize: Double

    enum CodingKeys: String, CodingKey {
        case askPrice = "ask_price"
        case bidPrice = "bid_price"
        case askSize = "ask_size"
        case bidSize = "bid_size"
    }
}

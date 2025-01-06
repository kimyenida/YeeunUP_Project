//
//  Orderbook.swift
//  YeeunUP
//
//  Created by 김예은 on 1/2/25.
//

struct OrderbookSocket: Codable {
    let type: String?
    let code: String?
    let timestamp: Double?
    let totalAskSize, totalBidSize: Double?
    let orderbookUnits: [OrderbookUnitSocket]?
    let streamType: String?
    let level: Double?

    enum CodingKeys: String, CodingKey {
        case type, code, timestamp
        case totalAskSize = "total_ask_size"
        case totalBidSize = "total_bid_size"
        case orderbookUnits = "orderbook_units"
        case streamType = "stream_type"
        case level
    }
}

struct OrderbookUnitSocket: Codable {
    let askPrice, bidPrice: Double?
    let askSize, bidSize: Double?

    enum CodingKeys: String, CodingKey {
        case askPrice = "ask_price"
        case bidPrice = "bid_price"
        case askSize = "ask_size"
        case bidSize = "bid_size"
    }
}

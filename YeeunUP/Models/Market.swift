//
//  Market.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

struct Market: Codable {
    let market, koreanName, englishName: String
    let marketEvent: MarketEvent

    enum CodingKeys: String, CodingKey {
        case market
        case koreanName = "korean_name"
        case englishName = "english_name"
        case marketEvent = "market_event"
    }
}

struct MarketEvent: Codable {
    let warning: Bool
    let caution: Caution
}

struct Caution: Codable {
    let priceFluctuations, tradingVolumeSoaring, depositAmountSoaring, globalPriceDifferences: Bool
    let concentrationOfSmallAccounts: Bool

    enum CodingKeys: String, CodingKey {
        case priceFluctuations = "PRICE_FLUCTUATIONS"
        case tradingVolumeSoaring = "TRADING_VOLUME_SOARING"
        case depositAmountSoaring = "DEPOSIT_AMOUNT_SOARING"
        case globalPriceDifferences = "GLOBAL_PRICE_DIFFERENCES"
        case concentrationOfSmallAccounts = "CONCENTRATION_OF_SMALL_ACCOUNTS"
    }
}

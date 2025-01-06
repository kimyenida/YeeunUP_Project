//
//  SettingsAPIProceess.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

import Foundation

final class MarketAPIProceess: MarketAPIServiceProtocol {
    let networking = NetworkRouter<MarketEndPoint>()
    
    func getAllMarket() async throws -> [Market] {
        try await networking.request(.marketAll)
    }
    
    func getTradePrice(markets: [String]) async throws -> [Ticker] {
        try await networking.request(.ticker(markets: markets))
    }
}

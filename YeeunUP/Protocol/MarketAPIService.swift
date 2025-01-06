//
//  MarketAPIService.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

protocol MarketAPIServiceProtocol {
    func getAllMarket() async throws -> [Market]
    func getTradePrice(markets: [String]) async throws -> [Ticker]
}

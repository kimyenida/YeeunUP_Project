//
//  MarketViewModel.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

import Foundation
import Combine

enum Section {
    case main
}

final class MarketListViewModel {
    var apiService: MarketAPIServiceProtocol
    var socketService: SocketServiceProtocol
    
    var markets: [String: DefinedMarket] = [:]
    var selectedType: MarketType = .KRW

    var baseURL: String = ""
    var updatePublisher = PassthroughSubject<[DefinedMarket], Never>()
    
    init(baseURL: String) {
        self.baseURL = baseURL
        self.apiService = MarketAPIProceess()
        self.socketService = SocketManager(url: definedURL)
    }
    
    /* 조회가능한 종목 리스트 & 현재가 REST API */
    func fetchMarketList(_ completion: (() ->Void)?=nil) {
        Task {
            let allMarkets = try await apiService.getAllMarket()
            
            let filteredCodeList = allMarkets
                .filter { market in
                    market.market.hasPrefix(selectedType.rawValue)
                }
                .map { $0.market } // ["KRW-BTC", "KRW-ETH"]
            
            let allTicker = try await apiService.getTradePrice(markets: filteredCodeList)
            // allMarkets, allTicker 배열을 결합하여 DefinedMarket 객체 생성
            let definedMarkets: [DefinedMarket] = filteredCodeList.compactMap { marketCode in
                if let market = allMarkets.first(where: { $0.market == marketCode }),
                   let ticker = allTicker.first(where: { $0.market == marketCode }) {
                    return DefinedMarket(code: market.market, koreanName: market.koreanName, englishName: market.englishName, currentPrice: ticker.tradePrice, warning: market.marketEvent.warning, acctradePrice24: ticker.accTradePrice24H)
                }
                return nil
            }
            
            for market in definedMarkets {
                handleFetchMarket(definedData: market)
            }
            completion?()
        }
    }
    
    /* 실시간 현재가 소켓 */
    func connectTickerData() {
        socketService.connect()

        let codeList = Array(markets.keys)
        let message = """
                [
                {"ticket":"test example"},
                {"type":"ticker",
                "codes":\(codeList),
                "is_only_realtime": true
                },
                {"format":"DEFAULT"}
                ]
                """
        socketService.receiveData { [weak self] (result: Result<TickerSocket?, Error>) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
//                        print("Received data: \(data?.code), \(data?.tradePrice)")
                    if let data = data {
                        self.handleRealTimeMarket(realtimeInfo: data)
                    }
                case .failure(let error):
                    print("Failed to receive data: \(error)")
                }
            }
        }
        socketService.sendMessage(message: message)
    }

    private func handleRealTimeMarket(realtimeInfo: TickerSocket) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if var market = self.markets[realtimeInfo.code] {
                let warning = (realtimeInfo.marketWarning=="CAUTION") ? true : false
                
//                market.updateRealtimeInfo(currentPrice: Double(realtimeInfo.tradePrice), warning: warning, acctradePrice24: realtimeInfo.accTradePrice24H)
                if market.currentPrice != realtimeInfo.tradePrice {
                    market.updateRealtimeInfo(currentPrice: realtimeInfo.tradePrice, warning: warning, acctradePrice24: realtimeInfo.accTradePrice24H, isAnimated: true)
                    self.markets[realtimeInfo.code] = market
                } else {
                    market.updateRealtimeInfo(currentPrice: realtimeInfo.tradePrice, warning: warning, acctradePrice24: realtimeInfo.accTradePrice24H,isAnimated: false)
                    self.markets[realtimeInfo.code] = market
                }
//                self.markets[realtimeInfo.code] = market
                updateSnapShot()
            }
        }
    }
    
    private func handleFetchMarket(definedData: DefinedMarket) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            var definedMarket = DefinedMarket()
            var marketType: MarketType = .NONE
            switch definedData.code.split(separator: "-")[0] {
            case "KRW":
                marketType = .KRW
            case "BTC":
                marketType = .BTC
            case "USDT":
                marketType = .USDT
            default:
                marketType = .NONE
            }
            definedMarket.updateStaticInfo(code: definedData.code, koreanName: definedData.koreanName, englishName: definedData.englishName, currentPrice: definedData.currentPrice, marketType: marketType, acctradePrice24: definedData.acctradePrice24, warning: definedData.warning ?? false)
            
            self.markets[definedData.code] = definedMarket
            updateSnapShot()
        }
     }
    
    private func updateSnapShot() {
        var filteredMarkets = Array(self.markets.values)
            .filter { $0.marketType == selectedType }
        filteredMarkets.sort { $0.acctradePrice24 > $1.acctradePrice24 }

        updatePublisher.send(filteredMarkets)
    }
    
    func setMarketType(_ type: MarketType?) {
        if let type = type {
            selectedType = type
            fetchMarketList { [weak self] in
                guard let `self` = self else { return }
                connectTickerData()
            }
        }
    }
    
    func stopConnect() {
        socketService.disconnect()
    }
    
    deinit {
        stopConnect()
    }
}

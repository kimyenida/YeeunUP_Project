//
//  DefinedMarket.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

struct DefinedMarket: Hashable {
    var code: String = ""
    var koreanName: String = ""
    var englishName: String = ""
    var currentPrice: Double = 0.0
    var warning: Bool?
    var acctradePrice24: Double = 0.0
    
    var marketType: MarketType = .NONE
    
    var uniqueIdentifier: String {
        return "\(String(describing: code))-\(String(describing: currentPrice)))"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueIdentifier)
    }
    
    static func == (lhs: DefinedMarket, rhs: DefinedMarket) -> Bool {
        return lhs.uniqueIdentifier == rhs.uniqueIdentifier
    }
    
    mutating func updateStaticInfo(code: String, koreanName: String, englishName: String, currentPrice: Double, marketType: MarketType, acctradePrice24: Double, warning: Bool) {
        self.code = code
        self.koreanName = koreanName
        self.englishName = englishName
        self.currentPrice = currentPrice
        self.acctradePrice24 = acctradePrice24
        self.marketType = marketType
        self.warning = warning
    }
    
    mutating func updateRealtimeInfo(currentPrice: Double, warning: Bool, acctradePrice24: Double) {
        self.currentPrice = currentPrice
        self.warning = warning
        self.acctradePrice24 = acctradePrice24
    }
}

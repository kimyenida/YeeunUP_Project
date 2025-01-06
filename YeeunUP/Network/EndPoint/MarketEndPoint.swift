//
//  SettingsEndPoint.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

import Foundation

enum MarketEndPoint {
    case marketAll
    case ticker(markets: [String])
}

extension MarketEndPoint: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: NetworkDomain.upbit.url) else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .marketAll:
            return "v1/market/all"
        case .ticker:
            return "/v1/ticker"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .marketAll:
            var params = Parameters()
            params.updateValue(true, forKey: "is_details")
            return .requestParameters(body: nil, Encoding: .urlEncoding, query: params)
        case .ticker(let markets):
            var params = Parameters()
            let marketsString = markets.joined(separator: ",")
            params.updateValue(marketsString, forKey: "markets")
            return .requestParameters(body: nil, Encoding: .urlEncoding, query: params)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var contentType: HTTPContentType? {
        return .json
    }    
}

//
//  OrderBookEndPoint.swift
//  YeeunUP
//
//  Created by 김예은 on 1/2/25.
//

import Foundation

enum OrderBookEndPoint {
    case orderBook(markets: [String])
}

extension OrderBookEndPoint: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: NetworkDomain.upbit.url) else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .orderBook:
            return "v1/orderbook"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .orderBook(let markets):
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

//
//  NetworkDomain.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

import Foundation

enum NetworkDomain {
    case upbit
    
    var url: String {
        return "https://\(host)/"
    }
    
    var host: String {
        switch self {
        case .upbit:
            return "api.upbit.com"
        }
    }
}

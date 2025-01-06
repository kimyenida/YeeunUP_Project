//
//  EndPointType.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

import Foundation

enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

typealias HTTPHeaders = [String: String]
typealias Parameters = [String: Any]

enum HTTPContentType: String {
    case json   = "application/json"
    case txt    = "application/txt"
    case xml    = "application/xml"
}

enum HTTPTask {
    case request
    case requestParameters(body: Parameters?, Encoding: ParameterEncoding?, query: Parameters?)
}

protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
    var contentType: HTTPContentType? { get }
}

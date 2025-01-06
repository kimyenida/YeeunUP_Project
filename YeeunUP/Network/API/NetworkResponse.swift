//
//  APIResource.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

import Foundation

enum NetworkResponseError: String, Error {
    case authenticationError
    case badRequest
    case outdated
    case failed
    case noData
    case unableToDecode
    case invalidServerResponse
}

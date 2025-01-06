//
//  Parameters.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//
import Foundation

protocol ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

enum NetworkError: String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}

enum ParameterEncoding {
    case urlEncoding
    case jsonEncoding
    case urlAndJsonEncoding
    case UTF8Encoding
    
    func encode(urlRequest: inout URLRequest,
                       body: Parameters?,
                       query: Parameters?) throws {
        do {
            switch self {
            case .urlEncoding:
                guard let query = query else { return }
                try URLParameterEncoder().encode(urlRequest: &urlRequest, with: query)
                
            case .jsonEncoding:
                guard let body = body else { return }
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: body)
                
            case .urlAndJsonEncoding:
                guard let body = body,
                    let query = query else { return }
                try URLParameterEncoder().encode(urlRequest: &urlRequest, with: query)
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: body)
                
            case .UTF8Encoding:
                guard let body = body else { return }
                UTF8ParameterEncoder().encode(urlRequest: &urlRequest, with: body)
                
            }
        } catch {
            throw error
        }
    }
}

struct URLParameterEncoder: ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        guard let url = urlRequest.url else { throw NetworkError.missingURL }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            
            urlComponents.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                urlComponents.queryItems?.append(queryItem)
            }
            urlRequest.url = urlComponents.url
        }
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
}

struct JSONParameterEncoder: ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
     
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.httpBody = jsonAsData
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw NetworkError.encodingFailed
        }
    }
}


struct UTF8ParameterEncoder: ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) {
        var queryString: String = ""
        parameters.keys.enumerated().forEach { (idx, key) in
            queryString = (idx == 0) ? "\(key)=\(parameters[key]! )" : "\(queryString)&\(key)=\(parameters[key]! )"
        }
        
        let data = (queryString as NSString).data(using: String.Encoding.utf8.rawValue)
        
        urlRequest.httpBody = data
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
}


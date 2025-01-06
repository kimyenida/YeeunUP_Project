//
//  NetworkRoouter.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

import Foundation

class NetworkRouter<Endpoint: EndPointType> {
    enum Result<String> {
        case success
        case failure(String)
    }
    
    func request<T:Decodable>(_ route: Endpoint) async throws -> T {
        do {
            let request = try self.buildRequest(from: route)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkResponseError.invalidServerResponse
            }
            
            let result = handleNetworkResponse(httpResponse)
            
            switch result {
            case .success:
                let decodeData = try JSONDecoder().decode(T.self, from: data)
                return decodeData
            case .failure(let networkError):
                throw networkError
            }
        } catch {
            throw error
        }
    }
    
    func buildRequest(from route: EndPointType) throws -> URLRequest {
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        request.httpMethod = route.httpMethod.rawValue
        addAdditionalHeaders(route.headers, request: &request)
        
        do {
            try configureParamters(task: route.task, request: &request)
            return request
        } catch {
            throw error
        }
    }
    
    private func configureParamters(task: HTTPTask, request: inout URLRequest) throws {
        do {
            switch task {
            case .request:
                break
            case .requestParameters(body: let body, Encoding: let bodyEncoding, query: let query):
                try bodyEncoding?.encode(urlRequest: &request, body: body, query: query)
            }
        } catch {
            
        }
        
    }
    
    private func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    private func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<NetworkResponseError> {
        switch response.statusCode {
            case 200...299:
                return .success
            case 400:
                return .failure(NetworkResponseError.badRequest)
            case 401...500:
                return .failure(NetworkResponseError.authenticationError)
            case 501...599:
                return .failure(NetworkResponseError.badRequest)
            case 600:
                return .failure(NetworkResponseError.outdated)
            default:
                return .failure(NetworkResponseError.failed)
        }
    }
}

//
//  SocketManager.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

import Foundation

class SocketManager: NSObject, SocketServiceProtocol {    
    var onTickerUpdate: ((TickerSocket) -> Void)?
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession = URLSession(configuration: .default)

    private let baseURL: String
    private var pingTimer: Timer?
    
    init(url: String) {
        self.baseURL = url
    }
    
    func connect() {
        guard webSocketTask == nil || webSocketTask?.state == .completed else {
            // 이미 연결된 상태면 새로 연결하지 않음
            return
        }
        
        if let url = URL(string: baseURL) {
            webSocketTask = urlSession.webSocketTask(with: url)
            webSocketTask?.delegate = self
            webSocketTask?.resume()
        }
    }
    
    func receiveData<T: Decodable>(_ completion: @escaping (Result<T?, Error>) -> Void) {
        webSocketTask?.receive { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    do {
                        let decoder = JSONDecoder()
                        let decodedData = try decoder.decode(T.self, from: data)
                        completion(.success(decodedData))
                    }
                    catch {
                        print("receiveData socket Error = \(error)")
                    }
                case .string(let strData):
                    break
                }
            case .failure(let error):
                completion(.failure(error))
            }
            self.receiveData(completion)
        }
    }
    
    func sendMessage(message: String) {
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                print("WebSocket send error: \(error.localizedDescription)")
            } else {
                print("WebSocket send sucess")
            }
        }
    }
    
    /* 연결을 유지하기 위해 60초마다 ping */
    func ping() {
        guard pingTimer == nil else { return }
        pingTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] timer in
            guard let `self` = self else { return }

            self.webSocketTask?.sendPing(pongReceiveHandler: { error in
                if let error = error {
                    print("Upbit ping error: \(error.localizedDescription)")
                }
            })
        }
        pingTimer?.fire()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        pingTimer?.invalidate()
        pingTimer = nil
    }
}

extension SocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("open")
        ping()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("close \(reason)")
    }
}

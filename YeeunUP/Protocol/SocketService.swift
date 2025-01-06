//
//  MarketSocketService.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

protocol SocketServiceProtocol {
    var onTickerUpdate: ((TickerSocket) -> Void)? { get set }
    func connect()
    func disconnect()
    func receiveData<T: Decodable>(_ completion: @escaping (Result<T?, Error>) -> Void)
    func sendMessage(message: String)
    func ping()
}

//
//  OrderBookViewModel.swift
//  YeeunUP
//
//  Created by 김예은 on 1/2/25.
//

import Foundation
import Combine

final class OrderBookViewModel {
    var apiService: OrderBookAPIServiceProtocol
    var socketService: SocketServiceProtocol

    var marketData: DefinedMarket
    var orderBooks: [DefinedOrderBook] = []
    
    var updatePublisher = PassthroughSubject<[DefinedOrderBook], Never>()
    
    init(definedMarket: DefinedMarket) {
        self.marketData = definedMarket
        self.apiService = OrderBookAPIProcess()
        self.socketService = SocketManager(url: definedURL)
    }
    
    /* 선택한 마켓의 호가 RESET API */
    func fetchOrderBookData() {
        Task {
            do {
                let orderBooks = try await apiService.getOrderBook(markets: [self.marketData.code])
                for orderBook in orderBooks {
                    let unit = orderBook.orderbookUnits
                    let askPrice = unit.map { DefinedOrderBook(timeStamp: orderBook.timestamp, code: orderBook.market, price: $0.askPrice, type: .ask) }
                    let bidPrice = unit.map { DefinedOrderBook(timeStamp: orderBook.timestamp, code: orderBook.market, price: $0.bidPrice, type: .bid) }
                    self.orderBooks.append(contentsOf: askPrice)
                    self.orderBooks.append(contentsOf: bidPrice)
                }
            }
            catch {
                print("Error loading orderBook data: \(error)")
            }
        }
    }
    
    /* 선택한 마켓의 실시간 호가 소켓 */
    func connectOrderBookData() {
        socketService.connect()

        let codeList = [marketData.code]
        let message = """
                [
                {"ticket":"test example"},
                {"type":"orderbook",
                "codes":\(codeList),
                "is_only_realtime": true
                },
                {"format":"DEFAULT"}
                ]
                """
        socketService.receiveData { [weak self] (result: Result<OrderbookSocket?, Error>) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
//                    print("Received data orderbook: \(data?.code), \(data?.totalAskSize)")
                    self.handlePriceData(data: data)
                case .failure(let error):
                    print("Failed to receive data: \(error)")
                }
            }
        }
        socketService.sendMessage(message: message)
    }
    
    private func handlePriceData(data: OrderbookSocket?) {
        if let data = data {
            guard let orderbookUnits = data.orderbookUnits else { return }

            let askPrice = orderbookUnits.map { DefinedOrderBook(timeStamp: data.timestamp, code: data.code, price: $0.askPrice, type: .ask) }
            let bidPrice = orderbookUnits.map { DefinedOrderBook(timeStamp: data.timestamp, code: data.code, price: $0.bidPrice, type: .bid) }
            
            var arr: [DefinedOrderBook] = []
            arr.append(contentsOf: askPrice)
            arr.append(contentsOf: bidPrice)
            self.orderBooks = arr
            updateSnapShot()
        }
    }
    
    private func updateSnapShot() {
        self.updatePublisher.send(orderBooks)
    }
    
    func getMarketName() -> String {
        return marketData.koreanName
    }
    
    func stopConnect() {
        socketService.disconnect()
    }
}

//
//  AppCoordinator.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

import Foundation
import UIKit

class AppCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var children: [Coordinator] = []
    var rootController: UINavigationController
    
    init(navigationController: UINavigationController = UINavigationController()) {
        navigationController.isNavigationBarHidden = true
        self.rootController = navigationController
    }
    
    func start() {
        // marketVC(main)위에 splashVC 동작
        showMarketController()
        showSplashController()
    }
    
    func showMarketController() {
        let mainController = MarketViewController(viewModel: MarketListViewModel(baseURL: "wss://api.upbit.com/websocket/v1"), coordinator: self)
        rootController.pushViewController(mainController, animated: false)
    }
    
    func showSplashController() {
        let splashController = SplashViewController(coordinator: self)
        rootController.pushViewController(splashController, animated: false)
    }
    
    func showOrderBookController(marketData: DefinedMarket) {
        let orderBookVM = OrderBookViewModel(definedMarket: marketData)
        let orderBookVC = OrderBookViewController(viewModel: orderBookVM, coordinator: self)
        rootController.pushViewController(orderBookVC, animated: true)
    }
    
    func finishSplashController() {
        rootController.popToRootViewController(animated: true)
    }
    
    func finishOrderBookController() {
        rootController.popViewController(animated: true)
        
        if let marketVC = rootController.viewControllers.first(where: { $0 is MarketViewController }) as? MarketViewController {
            // 상세뷰 닫을 때 마켓뷰 데이터 소켓 재연결
            marketVC.viewModel?.connectTickerData()
        }
    }
    
    func getRootViewController() -> UINavigationController {
        return self.rootController
    }
    
    func destroy() {
        children.forEach { $0.destroy() }
        children.removeAll()
    }
}

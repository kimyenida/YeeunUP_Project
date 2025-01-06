//
//  Coordinator.swift
//  YeeunUP
//
//  Created by 김예은 on 1/3/25.
//

import UIKit

protocol Coordinator {
    var parentCoordinator: Coordinator? { get set }
    var children: [Coordinator] { get set }
    var rootController: UINavigationController { get set }
    func start()
    func destroy()
}

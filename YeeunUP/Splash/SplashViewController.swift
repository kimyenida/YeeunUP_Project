//
//  SplashViewController.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

import UIKit

final class SplashViewController: UIViewController {
    var coordinator: Coordinator?
    
    init(coordinator: Coordinator?) {
        super.init(nibName: nil, bundle: nil)
        self.coordinator = coordinator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let titleLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "splashLogo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playSplash()
    }
    
    private func setUI() {
        self.view.backgroundColor = UIColor(hexCode: "000080")
        self.view.addSubview(titleLogo)
        
        titleLogo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLogo.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            titleLogo.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            titleLogo.widthAnchor.constraint(equalToConstant: 200),
            titleLogo.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func playSplash() {
        DispatchQueue.main.asyncAfter(deadline: .now()+3.0, execute: { [weak self] in
            guard let `self` = self else { return }
            (self.coordinator as? AppCoordinator)?.finishSplashController()
        })
    }
}

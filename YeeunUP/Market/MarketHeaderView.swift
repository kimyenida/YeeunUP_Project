//
//  MarketHeaderView.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

import UIKit

final class MarketListHeaderView: UIView {
    private var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private var nameLabel: UILabel = {
        var lb = UILabel()
        lb.textColor = .white
        lb.font = .systemFont(ofSize: 14, weight: .medium)
        return lb
    }()
    
    private var priceLabel: UILabel = {
        var lb = UILabel()
        lb.textColor = .white
        lb.font = .systemFont(ofSize: 14, weight: .medium)
        lb.textAlignment = .center
        return lb
    }()
    
    private var cautionLabel: UILabel = {
        var lb = UILabel()
        lb.textColor = .white
        lb.font = .systemFont(ofSize: 14, weight: .medium)
        lb.textAlignment = . center
        return lb
    }()
    
    private var acctradePriceLabel: UILabel = {
        var lb = UILabel()
        lb.textColor = .white
        lb.font = .systemFont(ofSize: 14, weight: .medium)
        lb.textAlignment = .center
        return lb
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .black
        
        [nameLabel, priceLabel, cautionLabel, acctradePriceLabel].forEach { label in
            stackView.addArrangedSubview(label)
        }
        
        nameLabel.text = "종목명"
        priceLabel.text = "현재가"
        cautionLabel.text = "유의종목"
        acctradePriceLabel.text = "거래대금"

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

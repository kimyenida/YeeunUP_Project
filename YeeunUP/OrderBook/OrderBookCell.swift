//
//  OrderBookCell.swift
//  YeeunUP
//
//  Created by 김예은 on 1/2/25.
//

import UIKit

final class OrderBookCell: UITableViewCell {
    static let identifier = "OrderBookCell"

    private var priceLabel: UILabel = {
        var lb = UILabel()
        lb.textColor = .white
        lb.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        return lb
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(priceLabel)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            priceLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            priceLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
    }
    
    
    func configure(with data: DefinedOrderBook) {
        if let price = data.price {
            self.priceLabel.text = String(price)
        } else {
            self.priceLabel.text = ""
        }
        if data.type == .ask {
            self.contentView.backgroundColor = .blue.withAlphaComponent(0.5)
        } else if data.type == .bid {
            self.contentView.backgroundColor = .red.withAlphaComponent(0.5)
        }
    }
}

//
//  MarketCell.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//
import UIKit

final class MarketCell: UITableViewCell {
    static let identifier = "MarketCell"
    
    private var koreanNameLabel: UILabel = {
        var lb = UILabel()
        lb.textColor = .white
        lb.font = .systemFont(ofSize: 11)
        lb.numberOfLines = 2
        return lb
    }()
    
    private var englishNameLabel: UILabel = {
        var lb = UILabel()
        lb.textColor = .white
        lb.numberOfLines = 2
        lb.font = .systemFont(ofSize: 11)
        return lb
    }()
    
    private var currentPriceLabel: UILabel = {
        var lb = UILabel()
        lb.textColor = .white
        lb.font = .systemFont(ofSize: 11)
        lb.textAlignment = .right
        return lb
    }()
    
    private var cautionLabel: UILabel = {
        var lb = UILabel()
        lb.textColor = .white
        lb.font = .systemFont(ofSize: 11)
        lb.textAlignment = .center
        return lb
    }()
    
    private var acctradePriceLabel: UILabel = {
        var lb = UILabel()
        lb.textColor = .white
        lb.font = .systemFont(ofSize: 11)
        lb.textAlignment = .right
        return lb
    }()
    
    private var previousPrice: Double?
    private var previousType: MarketType?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        currentPriceLabel.backgroundColor = .clear
    }
    
    private func setupUI() {
        self.contentView.backgroundColor = .black
        let nameStack = UIStackView(arrangedSubviews: [
            koreanNameLabel,
            englishNameLabel,
        ])
        nameStack.axis = .vertical
        nameStack.distribution = .fillProportionally
        
        let stackView = UIStackView(arrangedSubviews: [
            nameStack,
            currentPriceLabel,
            cautionLabel,
            acctradePriceLabel
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    func configure(with market: DefinedMarket) {
        koreanNameLabel.text = market.koreanName
        englishNameLabel.text = market.englishName
        cautionLabel.text = (market.warning==true) ? "⚠️유의" : ""
        cautionLabel.textColor = .systemRed
        
        switch market.marketType {
        case .KRW:
            let accPrice = Int((market.acctradePrice24 / 1000000).rounded())
            currentPriceLabel.text = String(format: "%.3f", market.currentPrice)
            acctradePriceLabel.text = String("\(accPrice)백만")
        case .BTC:
            currentPriceLabel.text = String(format: "%.8f", market.currentPrice)
            acctradePriceLabel.text = String(format: "%.8f", market.acctradePrice24)
        case .USDT:
            currentPriceLabel.text = String(format: "%.6f", market.currentPrice)
            acctradePriceLabel.text = String(format: "%.3f", market.acctradePrice24)
        default: break
        }
        
        if previousPrice != market.currentPrice, previousType == market.marketType {
            animatePriceChange()
        }
        // 현재 가격 저장
        previousPrice = market.currentPrice
        previousType = market.marketType
    }

    private func animatePriceChange() {
        currentPriceLabel.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        
        // 애니메이션 실행
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let `self` = self else { return }
            self.currentPriceLabel.backgroundColor = .clear
        }
    }
}

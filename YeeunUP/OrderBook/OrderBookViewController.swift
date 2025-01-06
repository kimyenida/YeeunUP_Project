//
//  OrderBookViewController.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

import UIKit
import Combine

final class OrderBookViewController: UIViewController {
    private var closeBtn: UIButton = {
        var btn = UIButton()
        btn.tintColor = .white
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        return btn
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.text = "Order Book"
        return label
    }()
    
    private var tableView: UITableView = {
        let table = UITableView()
        table.bounces = false
        table.backgroundColor = .black
        table.rowHeight = UITableView.automaticDimension
        table.register(OrderBookCell.self, forCellReuseIdentifier: OrderBookCell.identifier)
        return table
    }()
    
    var viewModel: OrderBookViewModel?
    var coordinator: Coordinator?
    var dataSource: UITableViewDiffableDataSource<Section, DefinedOrderBook>?

    private var cancellable = Set<AnyCancellable>()
    
    init(viewModel: OrderBookViewModel, coordinator: Coordinator?) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.coordinator = coordinator
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureDataSource(tableView)
        viewModel?.connectOrderBookData()
    }

    private func bindViewModel() {
        self.viewModel?.updatePublisher
            .sink(receiveValue: { [weak self] definedData in
                guard let `self` = self else { return }
                self.updateSnapShot(data: definedData)
            })
            .store(in: &cancellable)
        viewModel?.fetchOrderBookData()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .black
        self.tableView.delegate = self
        
        self.view.addSubview(closeBtn)
        self.view.addSubview(titleLabel)
        self.view.addSubview(tableView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),
            closeBtn.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        closeBtn.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
        self.titleLabel.text = self.viewModel?.getMarketName()
    }

    func configureDataSource(_ tableView: UITableView) {
        dataSource = UITableViewDiffableDataSource<Section, DefinedOrderBook>(
            tableView: tableView,
            cellProvider: { tableView, IndexPath, orderBook in
                let cell = tableView.dequeueReusableCell(withIdentifier: OrderBookCell.identifier,for: IndexPath) as! OrderBookCell
                cell.configure(with: orderBook)
                return cell
            })
        var snapShot = NSDiffableDataSourceSnapshot<Section, DefinedOrderBook>()
        snapShot.appendSections([.main])
        snapShot.appendItems(viewModel?.orderBooks ?? [])
        dataSource?.apply(snapShot, animatingDifferences: false)
    }
    
    private func updateSnapShot(data: [DefinedOrderBook]) {
        var snapShot = NSDiffableDataSourceSnapshot<Section, DefinedOrderBook>()
        snapShot.appendSections([.main])
        
        snapShot.appendItems(data)

        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.dataSource?.apply(snapShot, animatingDifferences: false)
        }
    }
    
    @objc
    private func closeBtnTapped() {
        self.viewModel?.stopConnect()
        (self.coordinator as? AppCoordinator)?.finishOrderBookController()
    }
}

extension OrderBookViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
}

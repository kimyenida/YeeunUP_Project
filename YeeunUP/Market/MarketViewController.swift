//
//  MarketViewController.swift
//  YeeunUP
//
//  Created by 김예은 on 12/31/24.
//

import UIKit
import Combine

enum MarketType: String {
    case KRW, BTC, USDT, NONE
}

final class MarketViewController: UIViewController {
    private var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["KWR", "BTC", "USDT"])
        control.backgroundColor = .black
        control.selectedSegmentIndex = 0
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        return control
    }()
        
    private var tableView: UITableView = {
        let table = UITableView()
        table.bounces = false
        table.separatorColor = .lightGray
        table.backgroundColor = .black
        table.rowHeight = UITableView.automaticDimension
        table.register(MarketCell.self, forCellReuseIdentifier: MarketCell.identifier)
        return table
    }()
    
    var dataSource: UITableViewDiffableDataSource<Section, DefinedMarket>?
    var viewModel: MarketListViewModel?
    var coordinator: Coordinator?

    var timer: Timer?

    private var cancellable = Set<AnyCancellable>()
    
    init(viewModel: MarketListViewModel, coordinator: Coordinator?) {
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
        viewModel?.connectTickerData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .black
        self.tableView.delegate = self
        
        self.view.addSubview(segmentedControl)
        self.view.addSubview(tableView)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    private func bindViewModel() {
        self.viewModel?.updatePublisher
            .sink(receiveValue: { [weak self] data in
                guard let `self` = self else { return }
                self.updateSnapShot(data: data)
            })
            .store(in: &cancellable)
        viewModel?.fetchMarketList()
    }
    
    private func configureDataSource(_ tableView: UITableView) {
        dataSource = UITableViewDiffableDataSource<Section, DefinedMarket>(
            tableView: tableView,
            cellProvider: { tableView, IndexPath, market in
                let cell = tableView.dequeueReusableCell(withIdentifier: MarketCell.identifier,for: IndexPath) as! MarketCell
                cell.configure(with: market)
                return cell
            })
        var snapShot = NSDiffableDataSourceSnapshot<Section, DefinedMarket>()
        snapShot.appendSections([.main])
        if let values = viewModel?.markets.values {
            snapShot.appendItems(Array(values))
        } else {
            snapShot.appendItems([])
        }
        dataSource?.apply(snapShot, animatingDifferences: false)
    }
    
    private func updateSnapShot(data: [DefinedMarket]) {
        var snapShot = NSDiffableDataSourceSnapshot<Section, DefinedMarket>()
        snapShot.appendSections([.main])

        snapShot.appendItems(data)

        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.dataSource?.apply(snapShot, animatingDifferences: false)
        }
    }
    
    /* 3분 주기로 data fetch */
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 180.0, repeats: true) { [weak self] _ in
            guard let `self` = self else { return }
            self.viewModel?.fetchMarketList()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let types: [MarketType] = [.KRW, .BTC, .USDT]
        viewModel?.setMarketType(types[sender.selectedSegmentIndex])
    }
}

extension MarketViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let market = dataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        (self.coordinator as? AppCoordinator)?.showOrderBookController(marketData: market)
        self.viewModel?.stopConnect()   // 셀 클릭하여 상세뷰 진입 시 마켓 데이터 소켓 stop
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = MarketListHeaderView()
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
}

//
//  5dayController.swift
//  weather report
//
//  Created by alex surmava on 12.02.25.
//
import UIKit

class FiveDayController: UIViewController {
    
    private var city: String?
    private var fiveDayForecast: Forecast?
    private var table: UITableView!
    private var dailyForecasts: [[FiveForecast]] = []
    
    fileprivate func configureNavBar() {
        if let navBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBar.tintColor = .systemYellow
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            title = city
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        groupForecastsByDay()
        addGradientBackground(view: view)
        addBlurEffect(view: view)
        configureTable()
    }
    
    
    init(city: String, forecast: Forecast){
        self.city = city
        self.fiveDayForecast = forecast
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func groupForecastsByDay() {
        guard let forecasts = fiveDayForecast?.forecasts else { return }
        var groupedForecasts: [[FiveForecast]] = []
        var currentDayForecast: [FiveForecast] = []
        var currentDay = forecasts.first?.weekday
        
        
        for one in forecasts {
            if one.weekday != currentDay {
                groupedForecasts.append(currentDayForecast)
                currentDayForecast = []
                currentDay = one.weekday
            }
            currentDayForecast.append(one)
        }
        
        if !currentDayForecast.isEmpty {
            groupedForecasts.append(currentDayForecast)
        }
        dailyForecasts = groupedForecasts
    }
    
    private func configureTable() {
        table = UITableView(frame: .zero, style: .grouped)
        table.delegate = self
        table.dataSource = self
        table.sectionHeaderTopPadding = 0
        
        table.register(UINib(nibName: "ForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "ForecastTableViewCell")
        table.register(UINib(nibName: "ForecastHeader", bundle: nil),
                       forHeaderFooterViewReuseIdentifier: "ForecastHeader")
        
        view.backgroundColor = .gray.withAlphaComponent(0.3)
        table.backgroundColor = .clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.masksToBounds = false
        
        
        table.fillerRowHeight = 0
        table.isPrefetchingEnabled = false
        table.estimatedSectionHeaderHeight = UITableView.automaticDimension
        table.sectionHeaderHeight = UITableView.automaticDimension
        
        table.translatesAutoresizingMaskIntoConstraints = false
        table.contentInsetAdjustmentBehavior = .never
        table.backgroundColor = .clear
        table.tableHeaderView = UIView()
        view.addSubview(table)
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
}

extension FiveDayController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell", for: indexPath)
        if let forecastCell = cell as? ForecastTableViewCell {
            let fiveForecast = dailyForecasts[indexPath.section][indexPath.row]
            forecastCell.configure(with: fiveForecast)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyForecasts[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ForecastHeader")
        if let forecastHeader = header as? ForecastHeader {
            let fiveForecast = dailyForecasts[section].first
            forecastHeader.configure(with: fiveForecast!.weekday)
            forecastHeader.contentView.backgroundColor = .clear
        }
        return header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dailyForecasts.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            let clearBackgroundView = UIView()
            clearBackgroundView.backgroundColor = .clear
            header.backgroundView = clearBackgroundView

            header.layer.zPosition = 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44 
    }

}

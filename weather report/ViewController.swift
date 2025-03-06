//
//  ViewController.swift
//  weather report
//
//  Created by alex surmava on 04.02.25.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet private var addButton: UIButton!
    @IBOutlet private var refreshButton: UIButton!
    private let dbContext = DBManager.shared.persistentContainer.viewContext
    private var cities: [City] = []
    private var weatherData: [Weather] = []
    private var collectionView: UICollectionView!
    private var pageControl: UIPageControl!
    private var initialScrollDone = false
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let loadingView = UIView()
    private var errorView: ErrorView?
    private var savedPageIndex: Int = 0
    
    private let locationManager = CLLocationManager()
    private var currentLocationWeather: Weather?
    
    private var searchBar: UISearchBar!
    var filteredWeathers: [Weather] = []
    var isSearching = false


    override func viewDidLoad() {
        super.viewDidLoad()
//         Do any additional setup after loading the view.
        navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.clear
            ]
        addGradientBackground(view: view)
        addBlurEffect(view: view)
        configureSearchBar()
        configureCollectionView()
        configureLocationManager()
        configureAddButton()
        configureRefreshButton()

    }
    
    private func hideUI(isHidden: Bool) {
        collectionView.isHidden = isHidden
        
        if let pageControl = pageControl {
           pageControl.isHidden = isHidden
        }
        
        addButton.isHidden = isHidden
        refreshButton.isHidden = isHidden
    }
    
    private func fetchCities() {
        showLoading()
        self.hideUI(isHidden: true)
        DispatchQueue.global(qos: .background).async {
            let request = City.fetchRequest()
            do {
                let fetchedCities = try self.dbContext.fetch(request)
                DispatchQueue.main.async {
                    self.cities = fetchedCities
                    self.fetchWeathers()
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError()
                }
            }
        }
    }

    
    private func fetchWeathers() {
        Task.detached { [weak self] in
            guard let self = self else { return }
            await self.loadWeatherData()
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.pageControl.currentPage = self.savedPageIndex
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if !self.initialScrollDone {
                        self.scrollToCenterOnLaunch()
                    }
                }
            }
        }
    }

    private func loadWeatherData() async {
        weatherData.removeAll()
        
        if let currentLocationWeather = currentLocationWeather {
            self.weatherData.append(currentLocationWeather)
        }
        
        for city in cities {
            if let cityName = city.name, let weather = await fetchWeather(for: cityName) {
                weatherData.append(weather)
            } else {
                DispatchQueue.main.async {
                    self.showError()
                }
            }
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.configurePageControl()
            self.hideLoading()
            self.hideUI(isHidden: false)
        }
    }
    
    private func configureCollectionView() {
        let layout = WeatherLayout()
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "DailyWeatherCell", bundle: nil), forCellWithReuseIdentifier: "DailyWeatherCell")

    
        collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress)))
        
        
        view.backgroundColor = .gray.withAlphaComponent(0.3)
        collectionView.backgroundColor = .clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.masksToBounds = false
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let sideInset = (view.frame.width - (view.frame.width * 0.75))/2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = "Search city..."
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        searchBar.barTintColor = .clear
        searchBar.isTranslucent = true
        
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc
    private func handleLongPress(_ gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            let point = gesture.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: point) {
                
                if indexPath.row == 0 {
                    return
                }
                
                let city = cities[indexPath.row-1]
                let alert = UIAlertController(
                    title: "",
                    message: "Want to delete this city?",
                    preferredStyle: .actionSheet
                )
                
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [unowned self] _ in
                    dbContext.delete(city)
                    try? dbContext.save()
                    fetchCities()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alert, animated: true)
            }
        }
    }
    
    private func configureAddButton() {
        addButton.addTarget(self, action: #selector(handleAddCity), for: .touchUpInside)
    }
    
    private func configureRefreshButton() {
        refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
    }
    
    @objc
    private func handleRefresh() {
        savedPageIndex = pageControl.currentPage
        errorView?.removeFromSuperview()
        errorView = nil
        hideUI(isHidden: false)
        
        refreshButton.isEnabled = false
        fetchCities()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { 
            self.refreshButton.isEnabled = true
        }
    }
    
    @objc
    private func handleAddCity() {
        let popup = AddCityPopup(frame: UIScreen.main.bounds)
        popup.onAddCity = { [weak self] city in
            guard let self = self else { return }
            print("aqane")
            popup.hideWarning()
            var valid = true
            if city.isEmpty {
                popup.stopLoading()
                popup.showWarning(message: "City name cannot be empty.")
                valid.toggle()
            }
            if cities.contains(where: { $0.name?.lowercased() == city.lowercased() }) {
                popup.stopLoading()
                print("dssd")
                popup.showWarning(message: "\(city) is already added.")
                valid.toggle()
            }
            
            if valid {
                Task {
                    if let weather = await fetchWeather(for: city) {
                        self.weatherData.append(weather)
                        let newCity = City(context: self.dbContext)
                        newCity.name = city
                        do {
                            try self.dbContext.save()
                                self.fetchCities()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.scrollToPage(index: self.weatherData.count - 1)
                                    popup.dismiss()
                                }
                        } catch {
                            popup.stopLoading()
                            popup.showWarning(message: "Failed to save \(city). Please try again.")
                        }
                    } else {
                        popup.stopLoading()
                        popup.showWarning(message: "Failed to fetch weather for \(city). Please try again.")
                    }
                }
            }
        }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            keyWindow.addSubview(popup)
        }
    }
  
    
    private func configurePageControl() {
        pageControl = UIPageControl()
        pageControl.numberOfPages = weatherData.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .yellow
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)

        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10)
        ])
    }
    
    @objc
    private func pageControlChanged() {
        let index = pageControl.currentPage
        scrollToPage(index: index, animated: true)
    }
    
    private func scrollToCenterOnLaunch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if !self.weatherData.isEmpty{
                self.scrollToPage(index: 0)
                self.initialScrollDone = true
            }
        }
    }
    
    private func scrollToPage(index: Int, animated: Bool = true) {
        guard index >= 0, index < weatherData.count else { return }
        
        let itemWidth = collectionView.frame.width * 0.75
        let spacing: CGFloat = 20
        let sideInset = (collectionView.frame.width - itemWidth) / 2

        let targetX = CGFloat(index) * (itemWidth + spacing) - sideInset
        let maxOffset = collectionView.contentSize.width - collectionView.bounds.width
        let clampedOffsetX = max(0, min(targetX, maxOffset))

        collectionView.setContentOffset(CGPoint(x: clampedOffsetX, y: 0), animated: animated)
        pageControl.currentPage = index
        savedPageIndex = index
    }


    
    private func showError() {
        DispatchQueue.main.async {
            self.hideLoading()
            self.hideUI(isHidden: true)
            
            self.errorView?.removeFromSuperview()
            
            let errorView = ErrorView(frame: self.view.bounds)
            errorView.onReload = { [weak self] in
                self?.handleRefresh()
            }
            
            self.view.addSubview(errorView)
            self.errorView = errorView
        }
    }
    
    private func showLoading() {
        loadingView.frame = view.bounds
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.3)

        loadingIndicator.center = loadingView.center
        loadingIndicator.startAnimating()

        loadingView.addSubview(loadingIndicator)
        view.addSubview(loadingView)
    }

    private func hideLoading() {
        loadingIndicator.stopAnimating()
        loadingView.removeFromSuperview()
    }


}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredWeathers.count : weatherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyWeatherCell", for: indexPath) as! DailyWeatherCell
        let dataSource = isSearching ? filteredWeathers : weatherData
        guard indexPath.row < dataSource.count else {
            return UICollectionViewCell()
        }

        let weather = dataSource[indexPath.row]
        let isCurrentLocation = (!isSearching && indexPath.row == 0)

        cell.configure(with: weather, isCurrentLocation: isCurrentLocation)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let location = locationManager.location {
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude

                showLoading()
                
                Task {
                    if let forecast = await fetchForecastByCoordinates(lat: latitude, lon: longitude) {
                        hideLoading()
                        
                        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                        let forecastVC = FiveDayController(city: "Current Location", forecast: forecast)
                        navigationController?.pushViewController(forecastVC, animated: true)
                    } else {
                        showError()
                    }
                }
            } else {
                print("Failed to get current location coordinates")
            }
        } else {
            let city = cities[indexPath.row - 1]
            let cityName = city.name ?? "Unknown"

            showLoading()

            Task {
                if let forecast = await fetchForecast(for: cityName) {
                    hideLoading()

                    navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                    let forecastVC = FiveDayController(city: cityName, forecast: forecast)
                    navigationController?.pushViewController(forecastVC, animated: true)
                } else {
                    showError()
                }
            }
        }
    }


    
}
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width * 0.75
        let height = collectionView.frame.height * 0.70
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let layout = collectionView.collectionViewLayout as? WeatherLayout else { return }
        
        let itemWidth = collectionView.frame.width * 0.75
        let spacing = layout.minimumLineSpacing
        let sideInset = (collectionView.frame.width - itemWidth) / 2
        
        let offsetX = scrollView.contentOffset.x + sideInset
        let pageIndex = round(offsetX / (itemWidth + spacing))
        DispatchQueue.main.async {
            guard let pageControl = self.pageControl else {return}
            
            let safePageIndex = max(0, min(Int(pageIndex), self.weatherData.count - 1))
            pageControl.currentPage = safePageIndex
        }
    }
    
    private func updatePageControl() {
        let centerPoint = CGPoint(x: collectionView.contentOffset.x + collectionView.bounds.width / 2, y: collectionView.bounds.height / 2)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            pageControl.currentPage = indexPath.row
        }
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else if status == .denied {
            print("Location permission denied")
        }
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            fetchWeatherForCurrentLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }

    private func fetchWeatherForCurrentLocation(latitude: Double, longitude: Double) {
        Task {
            if let weather = await fetchWeatherByCoordinates(lat: latitude, lon: longitude) {
                DispatchQueue.main.async {
                    self.currentLocationWeather = weather
                    self.weatherData.removeAll()
                    self.fetchCities()
                }
            } else {
                print("Failed to fetch weather data")
            }
        }
    }
    
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
        } else {
            isSearching = true
            filteredWeathers = weatherData.filter { weather in
                weather.cityName.lowercased().contains(searchText.lowercased())
            }
        }
        collectionView.reloadData()
        
        pageControl.numberOfPages = isSearching ? filteredWeathers.count : weatherData.count
        pageControl.currentPage = 0 
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
        collectionView.reloadData()
    }

}


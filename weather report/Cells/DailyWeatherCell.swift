//
//  DailyWeatherCell.swift
//  weather report
//
//  Created by alex surmava on 04.02.25.
//

import UIKit
import Kingfisher

class DailyWeatherCell: UICollectionViewCell {
    
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var cityLabel: UILabel!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var verticalStackView: UIStackView!
    @IBOutlet private var cloudinessLabel: UILabel!
    @IBOutlet private var humidityLabel: UILabel!
    @IBOutlet private var windLabel: UILabel!
    @IBOutlet private var windDirection: UILabel!
    @IBOutlet private var currentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        self.layer.cornerRadius = 30
        self.layer.masksToBounds = false
        
        self.layer.shadowColor = UIColor.white.withAlphaComponent(0.6).cgColor
        self.layer.shadowOpacity = 0.7
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 15
    }
    
    func configure(with weather: Weather, isCurrentLocation: Bool) {
        print("Configuring cell at index with city:", weather.cityName, "isCurrentLocation:", isCurrentLocation)

        self.backgroundColor = getGradientColor(for: weather.temperature)
        
        cityLabel.text = "\(weather.cityName), \(weather.countryName)"
        temperatureLabel.text = "\(weather.temperature)°C | \(weather.weather)"
        cloudinessLabel.text = "\(weather.cloudiness) %"
        humidityLabel.text = "\(weather.humidity) %"
        windLabel.text = "\(weather.windSpeed) m/s"
        windDirection.text = "\(weather.windDirection)"
        
        currentLabel.isHidden = true
        if isCurrentLocation {
            currentLabel.isHidden = false
        }
        
        if let iconURL = weather.weatherIconURL {
            loadImage(from: iconURL)
        } else {
            iconImageView.image = UIImage(systemName: "cloud")
        }
    }
    
    private func loadImage(from url: URL) {
        iconImageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "cloud"),
            options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ]
        )
    }
    
    private func getGradientColor(for temperature: Int) -> UIColor {
        switch temperature {
        case ..<0: return UIColor.systemBlue.withAlphaComponent(0.4)
        case 0..<15: return UIColor.systemTeal.withAlphaComponent(0.4)
        case 15..<25: return UIColor.systemGreen.withAlphaComponent(0.4)
        case 25..<35: return UIColor.systemOrange.withAlphaComponent(0.4)
        default: return UIColor.systemRed.withAlphaComponent(0.4)
        }
    }
}

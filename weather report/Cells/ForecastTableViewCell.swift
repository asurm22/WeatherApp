//
//  ForecastTableViewCell.swift
//  weather report
//
//  Created by alex surmava on 12.02.25.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
    
    @IBOutlet private var time: UILabel!
    @IBOutlet private var weather: UILabel!
    @IBOutlet private var temp: UILabel!
    @IBOutlet private var weatherImageView: UIImageView!

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        self.backgroundColor = .clear
    }
    
    func configure(with forecast: FiveForecast){
        time.text = forecast.time
        weather.text = forecast.weather
        temp.text = "\(forecast.temperature)°C"
        
        if let iconURL = forecast.weatherIconURL {
            weatherImageView.kf.setImage(
                with: iconURL,
                placeholder: UIImage(systemName: "cloud"),
                options: [.transition(.fade(0.3)), .cacheOriginalImage]
            )
        } else {
            weatherImageView.image = UIImage(systemName: "cloud")
        }
    }
    
}

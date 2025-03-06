//
//  ForecastHeader.swift
//  weather report
//
//  Created by alex surmava on 12.02.25.
//

import UIKit

class ForecastHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var dayLabel: UILabel!
    
    func configure(with day: String){
        dayLabel.text = day
    }

}

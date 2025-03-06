//
//  URLStructs5day.swift
//  weather report
//
//  Created by alex surmava on 09.02.25.
//
import Foundation

struct Forecast {
    let countryName: String
    let cityName: String
    let forecasts: [FiveForecast]
}

struct FiveForecast {
    let time: String
    let temperature: Int
    let weather: String
    let weekday: String
    let weatherIconURL: URL?
}

struct ForecastResponse: Codable {
    let city: ForecastCity
    let list: [ForecastData]
}

struct ForecastCity: Codable {
    let name: String
    let country: String
}

struct ForecastData: Codable {
    let dt_txt: String
    let main: Main
    let weather: [WeatherCondition]
}

func fetchForecast(for city: String) async -> Forecast? {
    let apiKey = "82726459fbee26c60302040342a30266"
    let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=metric"

    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return nil
    }

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedData = try JSONDecoder().decode(ForecastResponse.self, from: data)

        let forecastEntries = decodedData.list.map { entry in
            let iconCode = entry.weather.first?.icon ?? "01d"
            let iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")

            return FiveForecast(
                time: getTime(from: entry.dt_txt),
                temperature: Int(entry.main.temp.rounded(.down)),
                weather: entry.weather.first?.description ?? "Unknown",
                weekday: getWeekday(from: entry.dt_txt),
                weatherIconURL: iconURL
            )
        }

        return Forecast(
            countryName: decodedData.city.country,
            cityName: decodedData.city.name,
            forecasts: forecastEntries
        )
    } catch {
        print("Error fetching forecast: \(error)")
        return nil
    }
}

func fetchForecastByCoordinates(lat: Double, lon: Double) async -> Forecast? {
    let apiKey = "82726459fbee26c60302040342a30266"
    let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"

    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return nil
    }

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedData = try JSONDecoder().decode(ForecastResponse.self, from: data)

        let forecastEntries = decodedData.list.map { entry in
            let iconCode = entry.weather.first?.icon ?? "01d"
            let iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")

            return FiveForecast(
                time: getTime(from: entry.dt_txt),
                temperature: Int(entry.main.temp.rounded(.down)),
                weather: entry.weather.first?.description ?? "Unknown",
                weekday: getWeekday(from: entry.dt_txt),
                weatherIconURL: iconURL
            )
        }

        return Forecast(
            countryName: decodedData.city.country,
            cityName: decodedData.city.name,
            forecasts: forecastEntries
        )
    } catch {
        print("Error fetching forecast: \(error)")
        return nil
    }
}

func getWeekday(from dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.timeZone = TimeZone(identifier: "UTC")

    if let date = formatter.date(from: dateString) {
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    return "Unknown"
}

func getTime(from dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    if let date = formatter.date(from: dateString) {
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    return "Unknown"
}


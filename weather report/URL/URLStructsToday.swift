//
//  URLStructs.swift
//  weather report
//
//  Created by alex surmava on 04.02.25.
//
import Foundation

struct Weather {
    let countryName: String
    let cityName: String
    let temperature: Int
    let weather: String
    let cloudiness: Int
    let humidity: Int
    let windSpeed: Double
    let windDirection: String
    let weatherIconURL: URL?
}

struct WeatherResponse: Codable {
    let sys: Sys
    let name: String
    let main: Main
    let weather: [WeatherCondition]
    let clouds: Clouds
    let wind: Wind
}

struct Sys: Codable {
    let country: String
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
}

struct WeatherCondition: Codable {
    let description: String
    let icon: String
}

struct Clouds: Codable {
    let all: Int
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
}

func fetchWeather(for city: String) async -> Weather? {
    let apiKey = "82726459fbee26c60302040342a30266"
    let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"

    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return nil
    }

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
        
        let temp = decodedData.main.temp.rounded(.down)
        let iconCode = decodedData.weather.first?.icon ?? "01d"
        let iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")

        return Weather(
            countryName: decodedData.sys.country ,
            cityName: decodedData.name,
            temperature: Int(temp),
            weather: decodedData.weather.first?.description ?? "Unknown",
            cloudiness: decodedData.clouds.all,
            humidity: decodedData.main.humidity,
            windSpeed: (decodedData.wind.speed * 3.6).rounded(.toNearestOrEven) ,
            windDirection: getWindDirection(from: decodedData.wind.deg),
            weatherIconURL: iconURL
        )
    } catch {
        print("Error fetching weather: \(error)")
        return nil
    }
}

func fetchWeatherByCoordinates(lat: Double, lon: Double) async -> Weather? {
    let apiKey = "82726459fbee26c60302040342a30266"
    let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
    
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return nil
    }

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
        
        let temp = decodedData.main.temp.rounded(.down)
        let iconCode = decodedData.weather.first?.icon ?? "01d"
        let iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")

        return Weather(
            countryName: decodedData.sys.country ,
            cityName: decodedData.name,
            temperature: Int(temp),
            weather: decodedData.weather.first?.description ?? "Unknown",
            cloudiness: decodedData.clouds.all,
            humidity: decodedData.main.humidity,
            windSpeed: (decodedData.wind.speed * 3.6).rounded(.toNearestOrEven),
            windDirection: getWindDirection(from: decodedData.wind.deg),
            weatherIconURL: iconURL
        )
    } catch {
        print("Error fetching weather: \(error)")
        return nil
    }
}


func getWindDirection(from degrees: Int) -> String {
    let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                      "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
    let index = Int((Double(degrees) / 22.5) + 0.5) % 16
    return directions[index]
}


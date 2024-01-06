//
//  weatherModel.swift
//  Zeelben_Shekhaliya_FE_8939147
//
//  Created by Zeel Shekhaliya on 2023-12-08.
//

import Foundation

// MARK: - Welcome
struct WeatherData: Decodable {
    let coord: Coord?
    let weather: [Weather]?
    let base: String?
    let main: Main?
    let visibility: Int?
    let wind: Wind?
    let clouds: Clouds?
    let dt: Int?
    let sys: Sys?
    let timezone, id: Int?
    let name: String?
    let cod: CodableValue?
    
    enum CodingKeys: String, CodingKey {
            case coord, weather, base, main, visibility, wind, clouds, dt, sys, timezone, id, name, cod
        }
}

// MARK: - Clouds
struct Clouds: Decodable {
    let all: Int?
}

// MARK: - Coord
struct Coord: Decodable {
    let lon, lat: Double?
}

// MARK: - Main
struct Main: Decodable {
    let temp, feelsLike, tempMin, tempMax: Double?
    let pressure, humidity: Int?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - Sys
struct Sys: Decodable {
    let type, id: Int?
    let country: String?
    let sunrise, sunset: Int?
}

// MARK: - Weather
struct Weather: Decodable {
    let id: Int?
    let main, description, icon: String?
}

// MARK: - Wind
struct Wind: Decodable {
    let speed: Double?
    let deg: Int?
}

struct CodableValue: Decodable {
    let intValue: Int?
    let stringValue: String?

    init(from decoder: Decoder) throws {
        if let intValue = try? decoder.singleValueContainer().decode(Int.self) {
            self.intValue = intValue
            self.stringValue = nil
        } else if let stringValue = try? decoder.singleValueContainer().decode(String.self) {
            self.intValue = nil
            self.stringValue = stringValue
        } else {
            throw DecodingError.typeMismatch(CodableValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected either Int or String"))
        }
    }
}

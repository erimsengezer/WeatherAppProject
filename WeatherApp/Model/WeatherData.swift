import Foundation
struct WeatherData : Codable {
    let consolidated_weather : [consolidated_weather]
    let title : String
}

struct consolidated_weather : Codable {
    let id : Int
    let weather_state_name : String
//    let weather_state_abbr : String
//    let wind_direction_compass : String
//    let created : String
//    let applicable_date : String
//    let min_temp : Int
//    let max_temp : Int
    let the_temp : Double
//    let wind_speed : Int
//    let wind_direction : Int
//    let air_pressure: Int
//    let humidity : Int
//    let visibility: Int
//    let predictability : Int
}

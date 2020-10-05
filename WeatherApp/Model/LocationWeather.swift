import Foundation

struct LocationWeather : Decodable {
    let id : Int
    let weather_state_name : String
    let the_temp : Double?
}

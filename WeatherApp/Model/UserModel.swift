import Foundation
import UIKit
import Alamofire
import CoreData
import SwiftEventBus


class UserModel: NSObject {
    
    private static let sharedInstance = UserModel()
    private override init() {}
    
    public static func getSharedInstance() -> UserModel! {
        return sharedInstance
    }
    
    var locationData = [LocationData]()
    var weatherData = [WeatherData]()
    var latitude : Double?
    var longitude : Double?
    var nearlyCities : [String]?
    
    func location(lat: Double, long: Double) {
        self.latitude = lat
        self.longitude = long
    }
    
    func getWeather() {
        var woeid = 0
        var url = URL(string: "")
        if latitude != nil && longitude != nil {
            url = URL(string: "https://www.metaweather.com/api/location/search/?lattlong=\(latitude!),\(longitude!)")
        }
        else {
            print("Location service is not working..")
        }
        AF.request(url ?? "https://www.metaweather.com/api/location/search/?lattlong=41.015137,28.979530").response { (response) in
            let result = response.data
            do {
                self.locationData = try JSONDecoder().decode([LocationData].self, from: result!)
                
                woeid = self.locationData[0].woeid
                
                AF.request("https://www.metaweather.com/api/location/\(woeid)/").response { (res) in
                    let result = res.data
                    do {
                        
                        JSONDecoder().keyDecodingStrategy = .convertFromSnakeCase
                        let json = try JSONDecoder().decode(WeatherData.self, from: result!)
                        SwiftEventBus.post("reloadEvent", sender: json.consolidated_weather)
                        
                        print(json.consolidated_weather[0].the_temp)
                    }
                    catch let error {
                        print("Error : \(error)")
                        print("Error Desc: \(error.localizedDescription)")
                    }
                }
                
            }catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

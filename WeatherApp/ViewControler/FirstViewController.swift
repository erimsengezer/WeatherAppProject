import UIKit
import Alamofire
import SwiftEventBus
import ProgressHUD

class FirstViewController: UIViewController {

    let cities = ["İstanbul", "Tekirdağ", "Kocaeli", "Bursa", "Edirne"]
    
    var userModel : UserModel!
    var weatherData = [WeatherData]()
    var consalidatedWeather = [consolidated_weather]()
    
    var cityName = ""
    var status = ""
    var temp = 0.0
    var dateString = ""
    var weathers = [LocationWeather]()
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userModel = UserModel.getSharedInstance()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.userModel = UserModel.getSharedInstance()
        self.userModel.getWeather()
        
        SwiftEventBus.onMainThread(self, name: "reloadEvent") { (result) in
            if let weather = result?.object as? [consolidated_weather] {
                self.consalidatedWeather = weather
                let intTemp = Int(round(1000 * self.consalidatedWeather[0].the_temp) / 1000)
                self.degreeLabel.text = "\(intTemp)°"
                self.cityLabel.text = self.userModel.locationData[0].title
                self.tableView.reloadData()
                self.statusLabel.text = self.consalidatedWeather[0].weather_state_name
            }
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkConnection()
    }
    
    func checkConnection() {
        if !ConnectionControl.isConnectedToInternet() {
            print("Not Connection")
            let alert = UIAlertController(title: "İnternet Bağlantısı yok", message: "Lütfen internet bağlantınızı kontrol edin.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension FirstViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.consalidatedWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell") as! HomeTableViewCell
        cell.cityLabel.text = (self.self.userModel.locationData[indexPath.row]).title
        cell.selectionStyle = .none
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "goToDetail" {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.cityName = self.cityName
            destinationVC.status = self.status
            destinationVC.temp = self.temp
            destinationVC.dateString = self.dateString
            destinationVC.weathers = self.weathers
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.isUserInteractionEnabled = false
        ProgressHUD.show()
        
        let woeid = self.userModel.locationData[indexPath.row].woeid
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        self.dateString = formatter.string(from: Date())
//        print("\(dateString.dropFirst(8))")
        
        let urlType = "\(woeid)/\(dateString)/"
        
        let url = URL(string: "https://www.metaweather.com/api/location/\(urlType)")
        
        AF.request(url!).response { (response) in

            do {
                JSONDecoder().keyDecodingStrategy = .convertFromSnakeCase
                let json = try JSONDecoder().decode([LocationWeather].self, from: response.data!)
                self.weathers = json
                
                
                self.cityName = self.userModel.locationData[indexPath.row].title
                self.status = self.consalidatedWeather[indexPath.row].weather_state_name
                self.temp = self.consalidatedWeather[indexPath.row].the_temp
                
                ProgressHUD.dismiss()
                self.view.isUserInteractionEnabled = true
                self.performSegue(withIdentifier: "goToDetail", sender: nil)
                

            }
            catch let error {
                print("Error: \(error)")
                print("Desc: \(error.localizedDescription)")
            }

        }
    }
    
}


import UIKit
import SwiftEventBus
import ProgressHUD
import Alamofire

class SecondViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var userModel : UserModel!
    var consalidatedWeather = [consolidated_weather]()
    
    
    var cityName = ""
    var status = ""
    var temp = 0.0
    var dateString = ""
    var weathers = [LocationWeather]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        ProgressHUD.show()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.userModel = UserModel.getSharedInstance()
        self.userModel.getWeather()
        
        SwiftEventBus.onMainThread(self, name: "reloadEvent") { (result) in
            self.view.isUserInteractionEnabled = false
            if let weather = result?.object as? [consolidated_weather] {
                self.consalidatedWeather = weather
                self.tableView.reloadData()
                ProgressHUD.dismiss()
                self.view.isUserInteractionEnabled = true
            }
        }
    }


}

extension SecondViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.consalidatedWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.userModel.locationData[indexPath.row].title
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


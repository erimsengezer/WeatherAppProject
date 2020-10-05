import UIKit
import SwiftEventBus

class DetailViewController: UIViewController {
    
    var cityName = ""
    var status = ""
    var temp = 0.0
    var dateString = ""
    var dates = [String]()
    
    
    var weathers = [LocationWeather]()
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cityLabel.text = cityName
        self.statusLabel.text = status
        let intTemp = Int((temp * 1000) / 1000)
        self.tempLabel.text = "\(intTemp)°"
        print("COUNT !: \(weathers.count)")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        dateSettings()
        setupLayout()
    }
    
    func setupLayout() {
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cityLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            cityLabel.widthAnchor.constraint(equalTo: view.widthAnchor),


            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: cityLabel.topAnchor, constant: 50),
            statusLabel.widthAnchor.constraint(equalTo: view.widthAnchor),

            tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tempLabel.topAnchor.constraint(equalTo: statusLabel.topAnchor, constant: 50),
            tempLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.topAnchor.constraint(equalTo: tempLabel.topAnchor, constant: 70),
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor)


        ])


    }
    
    
    func dateSettings() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        for date in 0...6 {
            let date = formatter.string(from: Date().addingTimeInterval(TimeInterval(86400 * date)))
            self.dates.append(String(date.dropLast(5)))
        }
        print("DATES !: \(self.dates)")
    }
    
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DetailCollectionViewCell
        cell.dateLabel.text = self.dates[indexPath.row]
        cell.statusLabel.text = self.weathers[indexPath.row].weather_state_name
        let intTemp = Int((1000 * self.weathers[indexPath.row].the_temp!) / 1000)
        cell.tempLabel.text = "\(intTemp)°"
        return cell
    }
    
    
}

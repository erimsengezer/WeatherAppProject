import UIKit
import CoreLocation

class LaunchScreenViewController: UIViewController, CLLocationManagerDelegate {
    
    let timer = 3.0
    let locationManager = CLLocationManager()
    var userModel : UserModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userModel = UserModel.getSharedInstance()
        checkInternetConnection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func checkInternetConnection() {
        Timer.scheduledTimer(withTimeInterval: timer, repeats: true) { (timer) in
            if ConnectionControl.isConnectedToInternet() {
                self.getCurrentLocation()
                print("LOG !")
                timer.invalidate()
            }
            else {
                let alert = UIAlertController(title: "İnternet Bağlantısı Yok", message: "Lütfen internet bağlantınızı kontrol ediniz", preferredStyle: .alert)
                let okButton = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    
    func getCurrentLocation() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.changeScreen()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.userModel.location(lat: locValue.latitude, long: locValue.longitude)
    }
    
    public func changeScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "tabBar")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }

}

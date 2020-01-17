import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
  
  @IBOutlet weak var customSwitch: UISwitch!
  @IBOutlet weak var degrees: UILabel!
  
  let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
  let APP_ID = "put your App ID in here"
  /***Get your own App ID at https://openweathermap.org/appid ****/
  
  let locationManager = CLLocationManager()
  let weatherDataModel = WeatherDataModel()
  
  @IBOutlet weak var weatherIcon: UIImageView!
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //Toggle button
    toggleButton()
    kelvinsToCelcius()
    temperatureLabel.sizeToFit()
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  //MARK: - Networking
  /***************************************************************/
  func getWeatherData(url: String, parameters: [String : String]){
    
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
      response in
      if response.result.isSuccess {
        print("Success! Got the weather data.")
        
        let weatherJSON : JSON = JSON(response.result.value!)
        self.updateWeatherData(json: weatherJSON)
        
      } else {
        print("Error \(String(describing: response.result.error))")
        self.cityLabel.text = "Connections Issues"
      }
    }
  }
  
  //MARK: - JSON Parsing
  /***************************************************************/
  
  func updateWeatherData(json: JSON){
    
    
    if let tempResult = json["main"]["temp"].double {
      weatherDataModel.temperature = Int(tempResult - 273.15)
      weatherDataModel.city = json["name"].stringValue
      weatherDataModel.condition = json["weather"][0]["id"].intValue
      weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
      updateUIWitheWeatherData()
    } else {
      cityLabel.text = "Weather Unavailable."
    }
  }
  
  //MARK: - UI Updates
  /***************************************************************/
  
  func updateUIWitheWeatherData() {
    cityLabel.text = weatherDataModel.city
    temperatureLabel.text = "\(weatherDataModel.temperature)°"
    weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
  }
  
  //MARK: - Location Manager Delegate Methods
  /***************************************************************/
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations[locations.count - 1]
    if location.horizontalAccuracy > 0 {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      print("Longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
      let latitude = String(location.coordinate.latitude)
      let longitude = String(location.coordinate.longitude)
      let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
      getWeatherData(url: WEATHER_URL, parameters: params)
    } else {
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
    cityLabel.text = "Location unavailable."
  }
  
  //MARK: - City Delegate methods
  /***************************************************************/
  
  func userEnteredANewCityName(city: String) {
    let params: [String : String] = ["q" : city, "appid" : APP_ID]
    getWeatherData(url: WEATHER_URL, parameters: params)
  }
  
  //Toggle button
  func toggleButton() {
    customSwitch.tintColor = UIColor.green
    customSwitch.thumbTintColor = UIColor.white
    customSwitch.onTintColor = UIColor.green
    customSwitch.isOn = false
  }
  @IBAction func toggleButtonPressed(_ sender: UISwitch) {
    kelvinsToCelcius()
  }
  
  func kelvinsToCelcius() {
    let kelvins = 273.15
    if customSwitch.isOn {
      degrees.text = "Kelvins"
      temperatureLabel.text = "\(weatherDataModel.temperature + Int(kelvins))K"
    } else {
      degrees.text = "Celsius"
      temperatureLabel.text = "\(weatherDataModel.temperature)°"
    }
  }
  
  //PrepareForSegue Method
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "changeCityName"{
      let destinationVC = segue.destination as! ChangeCityViewController
      destinationVC.delegate = self
    }
  }
}



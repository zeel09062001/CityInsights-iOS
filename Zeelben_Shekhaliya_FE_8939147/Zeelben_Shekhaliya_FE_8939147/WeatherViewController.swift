//
//  WeatherViewController.swift
//  Zeelben_Shekhaliya_FE_8939147
//
//  Created by Zeel Shekhaliya on 2023-12-07.
//

import UIKit
import Foundation
import CoreLocation

var weatherDataSwift : WeatherData? = nil

class WeatherViewController: ExtensionViewController {
    
    var enteredLocation : String?
    
    @IBOutlet weak var cityNameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatheLbl: UILabel!
    @IBOutlet weak var humadityView: UIView!
    @IBOutlet weak var weatherDegeree: UILabel!
    @IBOutlet weak var windValue: UILabel!
    @IBOutlet weak var humadityValue: UILabel!
    @IBOutlet weak var windView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.startLoading()
        setUpFormatting()
    Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        fetchWeatherData { [weak self] in
            self?.updateUI()
            self?.updateTime()
            
            self?.title = "Weather"
            self?.navigationController?.navigationBar.titleTextAttributes    = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        
        let plusButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonTapped))
        plusButton.tintColor = .white
        navigationItem.rightBarButtonItem = plusButton
    }
    
    @objc func plusButtonTapped() {
        showAlertMessage(title: "Enter your new destination here!")
    }
    
    @IBAction func changeCityButtonAction(_ sender: Any) {
    }
    
    func updateUI() {
        guard let weatherData = weatherDataSwift else { return }
        weatheLbl.text = weatherData.weather?.first?.description
        weatherDegeree.text =  String(format: "%.2f", kelvinToCelsius(weatherData.main?.temp ?? 0.0)) + "°C"
        humadityValue.text = "\(weatherData.main?.humidity ?? 0)"
        windValue.text = "\(weatherData.wind?.speed ?? 0.0) Km/h"
        cityNameLbl.text = "\(weatherData.name ?? ""), \(weatherData.sys?.country ?? "")"
        
        if let firstWeatherCondition = weatherData.weather?.first {
          
            let iconCode = firstWeatherCondition.icon ?? ""
            WeatherIcon(iconCode: iconCode) { iconImage in
                DispatchQueue.main.async {
                    self.weatherImage.image = iconImage
                    self.stopLoading()
                }
            }
        } else {
            print("No weather conditions available")
            showAlertMessage(title: "Please enter valid city name.")
            stopLoading()
        }
    }
    
    @objc func updateTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "hh:mm a" // Adjust the format as needed

        let currentTime = Date()
        let formattedTime = dateFormatter.string(from: currentTime)

        timeLbl.text = formattedTime
    }
    
    func showAlertMessage(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .alphabet
        }

        let changeCity = UIAlertAction(title: "Change city name", style: .default) { [unowned alert] (action) in
            if let textField = alert.textFields?.first {
                self.enteredLocation = textField.text
                
                self.fetchWeatherData { [weak self] in
                    self?.updateTime()
                    self?.updateUI()
                    self?.cityNameLbl.text = self?.enteredLocation
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(changeCity)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setUpFormatting() {
        
        humadityView.layer.cornerRadius = 10
        windView.layer.cornerRadius = 10
    }
    
    //API call
    func fetchWeatherData(completion: @escaping () -> Void) {
        startLoading()
        let apiKey = "9536bcbf0ebf29b188f2558a53b045ba"
        let location = enteredLocation ?? "waterloo,canada"
        let apiUrl = "https://api.openweathermap.org/data/2.5/weather?q=\(location)&APPID=\(apiKey)"

        if let url = URL(string: apiUrl) {
            let session = URLSession.shared

            let task = session.dataTask(with: url) { [weak self] (data, response, error) in
                guard let self = self else { return }

                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    self.handleNetworkError(error: error)
                    return
                }

                if let data = data {
                    do {
                        let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                        weatherDataSwift = weatherData
                       
                        DispatchQueue.main.async {
                            completion()
                        }
                    } catch {
                        print("Error decoding JSON: \(error.localizedDescription)")
                    }
                }
            }
            task.resume()
        }
    }
    
    //API call for weather Image
    func WeatherIcon(iconCode: String, completion: @escaping (UIImage?) -> Void) {
            let iconURL = "https://openweathermap.org/img/w/\(iconCode).png"
            
            guard let url = URL(string: iconURL) else {
                print("Invalid icon URL")
                completion(nil)
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error : \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                if let data = data, let iconImage = UIImage(data: data) {
                    completion(iconImage)
                } else {
                    completion(nil)
                }
            }.resume()
        }
}

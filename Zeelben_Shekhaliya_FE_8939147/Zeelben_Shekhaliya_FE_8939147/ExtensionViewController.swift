//
//  ExtensionViewController.swift
//  Zeelben_Shekhaliya_FE_8939147
//
//  Created by Zeel Shekhaliya on 2024-01-04.
//

import UIKit

class ExtensionViewController: UIViewController {

    var activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func navigateToPushViewController(myViewController : UIViewController, withIdentifier : String) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: withIdentifier)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func getCurrentDateFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        
        return formattedDate
    }

    func startLoading() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false // Disable user interaction while loading
    }
    func stopLoading() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true // Enable user interaction after loading
    }
    
    func kelvinToCelsius(_ kelvin: Double) -> Double {
        return kelvin - 273.15
    }
    func handleNetworkError(error: Error) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Network Error", message: error.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            print("Error: \(error)")
        }
    }
}

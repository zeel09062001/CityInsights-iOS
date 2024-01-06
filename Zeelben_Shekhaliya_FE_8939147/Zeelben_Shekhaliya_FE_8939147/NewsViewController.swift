//
//  NewsViewController.swift
//  Zeelben_Shekhaliya_FE_8939147
//
//  Created by Zeel Shekhaliya on 2023-12-07.
//

import UIKit


var newsDataToPrint : NewsDataModel? = nil

class NewsViewController:  ExtensionViewController, UITableViewDelegate, UITableViewDataSource {

    var locationData : String?
    let apiKey = "1f2bc91deaee4dfab0bcadef72aa5155"
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "LocalNewsTableViewCell", bundle: nil), forCellReuseIdentifier: "LocalNewsTableViewCell")

        callNewsAPI(query: locationData ?? "waterloo", fromDate: "2024/01/01" , apiKey: apiKey)
        
        let plusButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonTapped))
        plusButton.tintColor = .white
        navigationItem.rightBarButtonItem = plusButton
    }
    
    @objc func plusButtonTapped() {
        showAlertMessage(title: "Enter your new destination here!")
    }
    
    @IBAction func changeCityButtonAction(_ sender: Any) {
    }
    
    
//    tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsDataToPrint?.articles.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : LocalNewsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LocalNewsTableViewCell", for: indexPath) as! LocalNewsTableViewCell
    
        cell.authorLabel.text = newsDataToPrint?.articles[indexPath.row].author
        cell.titleLabel.text = newsDataToPrint?.articles[indexPath.row].title
        cell.descriptionLabel.text = newsDataToPrint?.articles[indexPath.row].description
        cell.sourceLabel.text = newsDataToPrint?.articles[indexPath.row].source.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                newsDataToPrint?.articles.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        
    func showAlertMessage(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .alphabet
        }

        let changeCity = UIAlertAction(title: "Change City", style: .default) { [self, unowned alert] (action) in
            if let textField = alert.textFields?.first {
                self.locationData = textField.text
                self.callNewsAPI(query: self.locationData ?? "waterloo", fromDate: "2024/01/01" , apiKey: self.apiKey)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(changeCity)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    func reloadDataWithAnimation() {
            UIView.transition(with: tableView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
        }, completion: nil)
    }
}

extension NewsViewController {
    
    //API call
    func callNewsAPI(query: String, fromDate: String, apiKey: String) {
        // Set up the API endpoint URL with dynamic values
        startLoading()
        
        let urlString = "https://newsapi.org/v2/everything?q=\(query)&from=\(fromDate)&sortBy=publishedAt&apiKey=\(apiKey)"

        // Create URL from the string
        if let url = URL(string: urlString) {
            let session = URLSession.shared
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    self.handleNetworkError(error: error)
                    
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let newsData = try decoder.decode(NewsDataModel.self, from: data)
    
                    DispatchQueue.main.async {
                        self.stopLoading()
                        newsDataToPrint = newsData
                        self.tableView.reloadData()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.reloadDataWithAnimation()
                        }
                    }

                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
            task.resume()
        }
    }
}

//
//  FirstViewController.swift
//  InnerWorld
//
//  Created by Jacky Tang on 23/8/18.
//  Copyright © 2018 Jacky Tang. All rights reserved.
//

import UIKit
import MapKit
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
//    var appEngine = AppEngine.shared()
    var model = Model.shared()
    var darkSkyWeatherDataManager = DarkSkyWeatherDataManager.shared
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    @IBOutlet weak var currentDateLabel: UILabel!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.refreshDiaryData()
    }

    func refreshDiaryData(){
        model.search = searchBar.text!
        model.location = ""
        model.mood = ""
        model.filterHomePageDiaryList()
        self.diaryTableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.diaryTableView.reloadData()

        // get current weather condition from Rest API
        darkSkyWeatherDataManager.weatherDataAt(latitude: -37.767494, longitude: 144.945227) { currentWeather, error in
            DispatchQueue.main.async {
                if let weatherImage = currentWeather?.currently.icon, let date = currentWeather?.currently.time {
                    self.currentWeatherImage.image = UIImage(named: weatherImage)
                    self.currentDateLabel.text = "\("\(date)".prefix(10))"
                }
                let geoCoder = CLGeocoder()
                let location = CLLocation(latitude: -37.767494, longitude: 144.945227) // <- New York
                geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in
                    placemarks?.forEach { (placemark) in
                        if let city = placemark.locality {
                            self.currentLocationLabel.text = city
                        }
                    }
                })
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.model.filterHomePageDiaryList()
        self.diaryTableView.reloadData()
    }

    @IBOutlet weak var diaryTableView: UITableView!

    @IBAction func clearFilterButtonTapped(_ sender: Any) {
        model.search = ""
        model.location = ""
        model.mood = ""
        model.filterHomePageDiaryList()
        self.diaryTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(model.filteredDiaries.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeViewControllerTableViewCell
        
        cell.locationLabel.text = model.filteredDiaries[indexPath.row].location
        cell.weatherIcon.image = UIImage(named: (model.filteredDiaries[indexPath.row].weather! + ".png"))
        cell.tittleLabel.text = model.filteredDiaries[indexPath.row].title
//        let formatter = DateFormatter()
//        cell.dateLabel.text = formatter.string(from: appEngine.filteredDiaries[indexPath.row].date! as Date)
        
//        cell.locationLabel.text = appEngine.diaries[indexPath.row].location
//        cell.weatherIcon.image = UIImage(named: (appEngine.diaries[indexPath.row].weather! + ".png"))
//        cell.tittleLabel.text = appEngine.diaries[indexPath.row].title
//
//        let formatter = DateFormatter()
//        cell.dateLabel.text = formatter.string(from: appEngine.diaries[indexPath.row].date! as Date)
        return(cell)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(165)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.readingDiary = model.filteredDiaries[indexPath.row]
        performSegue(withIdentifier: "HomeToReadSegue", sender: nil)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            self.model.deleteDiary(self.model.getDiaryIndex(diary: self.model.filteredDiaries[indexPath.row]))
            self.model.filteredDiaries.remove(at: indexPath.row)
            self.diaryTableView.deleteRows(at: [indexPath], with: .automatic)
            
            completion(true)

            let alert = UIAlertController(title: "The diary has been deleted", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {Void in})
            alert.addAction(okAction)
            alert.setValue(NSAttributedString(string: alert.title!, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium), NSAttributedStringKey.foregroundColor : UIColor.red]), forKey: "attributedTitle")
            self.present(alert, animated: true, completion: nil)
        }

        action.image = #imageLiteral(resourceName: "trashBin")
        action.backgroundColor = .red
        return action
    }
}


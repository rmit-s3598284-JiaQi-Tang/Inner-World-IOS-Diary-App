//
//  FirstViewController.swift
//  InnerWorld
//
//  Created by Jacky Tang on 23/8/18.
//  Copyright © 2018 Jacky Tang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate, DarkSkyApiDelegate {
    var model = Model.shared()
    var darkSkyApi = DarkSkyApi.shared()
    let locationManager = CLLocationManager()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    @IBOutlet weak var currentDateLabel: UILabel!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.refreshDiaryData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.refreshDiaryData()
    }
    
    func refreshDiaryData(){
        model.searchTitle = searchBar.text!
        model.searchLocation = ""
        model.searchDate = ""
        model.filterHomePageDiaryList()
        self.diaryTableView.reloadData()
    }
    
    func apiCallback() {
        DispatchQueue.main.async {
            // Update UI
            let currentWeather = self.model.darkSkyApiData
            self.currentWeatherImage.image = UIImage(named: currentWeather.currently.icon)
            self.currentDateLabel.text = DarkSkyDataHandler.handleDate(date: currentWeather.currently.time)
            self.currentLocationLabel.text = "\(self.model.city) \(self.model.state)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.diaryTableView.reloadData()
        
        darkSkyApi.delegate = self

        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let changeLocation:NSArray =  locations as NSArray
        let currentLocation = changeLocation.lastObject as! CLLocation
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            guard let placemarks = placemarks else {
                return
            }
            if(placemarks.count > 0) {
                if let placeMark = placemarks.first {
                    self.getWeather(placeMark: placeMark)
                }
            } else if (error == nil && placemarks.count == 0) {
                print("none location callback");
            }
            else if ((error) != nil) {
                print("location error\(String(describing: error))");
            }
        }
    }

    func getWeather (placeMark: CLPlacemark) {
        if let location = placeMark.location {
            model.city = placeMark.locality!
            model.state = placeMark.administrativeArea!
            model.setLatLng(_lat: location.coordinate.latitude, _lng: location.coordinate.longitude)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.model.filterHomePageDiaryList()
        self.diaryTableView.reloadData()
    }

    @IBOutlet weak var diaryTableView: UITableView!

    @IBAction func clearFilterButtonTapped(_ sender: Any) {
        model.searchTitle = ""
        model.searchLocation = ""
        model.searchMood = ""
        model.searchDate = ""
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
        cell.moodIcon.image = UIImage(named: model.filteredDiaries[indexPath.row].mood! + ".png")
        cell.layer.cornerRadius = 15
        cell.layer.shadowColor = UIColor.red.cgColor
        cell.layer.shadowRadius = 20
        cell.layer.shadowOpacity = 20
        cell.layer.shadowOffset = CGSize(width: 20, height: 20)

        if (model.filteredDiaries[indexPath.row].date != nil) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MMM-yyyy"
            cell.dateLabel.text = formatter.string(from: model.filteredDiaries[indexPath.row].date! as Date)
        }
        else {
            cell.dateLabel.text = ""
        }
        return(cell)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(175)
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


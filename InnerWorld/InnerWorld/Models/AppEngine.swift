//
//  AppEngine.swift
//  InnerWorld
//
//  Created by Jacky Tang on 30/8/18.
//  Copyright © 2018 Jacky Tang. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AppEngine {

    var diaryList: [Diary]
    var filteredDiaryList: [Diary]
    var user: User
    var diaryLocations: [String]
    var currentLocation: String = "Melbourne"
    var currentWeather: String = "rainning"
    var creatingDiary: Diary
    var readingDiary: Diary
    
    var diaries = [Diary_CD]()
    var filteredDiaries = [Diary_CD]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext: NSManagedObjectContext
    
    // Shared Properties
    private static var sharedInstance: AppEngine = {
        let appModel = AppEngine()
        return appModel
    }()
    
    // Initialization
    private init() {
        diaryList = [
            Diary(id: 1, title: "A happy day in St Kilda", date: "08-Aug-2018", mood: "smile", weather: "clear-day", location: "St Kilda, Melbourne", photo: "prototype-diaryPicture", content: "Today, I went to St kilda beach with my Indian brother Manana. We took a lot of awesome pictures there! what a happy day!"),
            Diary(id: 2, title: "Lost 100$ in China Town", date: "6-Aug-2018", mood: "sad", weather: "rain", location: "China Town, Melbourne", photo: "prototype-diaryPicture2", content: "Today, I went to China Town alone for some Chinese food. I lost my precious 100$! what a bad day!"),
            Diary(id: 3, title: "Learning Swift is fun!", date: "1-Aug-2018", mood: "happy", weather: "cloudy", location: "RMIT, Melbourne", photo: "prototype-diaryPicture3", content: "Today, I went to RMIT with my friend Linh, we learned a lot IOS stuff from Fardin. what a good day!")
        ]
        user = User(nickName: "Another Dude", birthDay: "3-Dec-1993", password: "", hint: "There's no password")
        filteredDiaryList = diaryList
        diaryLocations = ["Melbourne"]
        creatingDiary = Diary(id: -1, title: "", date: "", mood: "", weather: "", location: "", photo: "", content: "")
        readingDiary = Diary(id: -1, title: "", date: "", mood: "", weather: "", location: "", photo: "", content: "")
        
        managedContext = appDelegate.persistentContainer.viewContext
        loadDiariesFromCoreData()
        filteredDiaries = diaries
    }
    
    // Accessors
    class func shared() -> AppEngine {
        return sharedInstance
    }
    
    func updateDb() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Error updating: \(error)")
        }
    }
    
    func deleteDiary(_ indexPath: IndexPath) {
        let diary = diaries[indexPath.item]
        diaries.remove(at: indexPath.item)
        managedContext.delete(diary)
        updateDb()
    }
    
    func loadDiariesFromCoreData() {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Diary_CD")
            let result = try managedContext.fetch(fetchRequest)
            diaries = result as! [Diary_CD]
        }
        catch let error as NSError
        {
            print("Could not fetch: \(error)")
        }
    }
    
    func saveDiaryToCoreData(diary :Diary_CD, existing: Diary_CD!) {
        let entity = NSEntityDescription.entity(forEntityName: "Diary_CD", in: managedContext)
        
        if let _ = existing {
            existing.title = diary.title
            existing.content = diary.content
            existing.mood = diary.mood
            existing.weather = diary.weather
            existing.location = diary.location
            existing.date = diary.date
            existing.photo = diary.photo
        }
        else {
            let newDiary = NSManagedObject(entity: entity!, insertInto: managedContext) as! Diary_CD
            newDiary.setValue(diary.title, forKey: "title")
            newDiary.setValue(diary.content, forKey: "content")
            newDiary.setValue(diary.mood, forKey: "mood")
            newDiary.setValue(diary.weather, forKey: "weather")
            newDiary.setValue(diary.location, forKey: "location")
            newDiary.setValue(diary.date, forKey: "date")
            newDiary.setValue(diary.photo, forKey: "photo")
            diaries.append(newDiary)
        }
        updateDb()
    }
    
    func getDiary(_ indexPath: IndexPath) -> Diary_CD{
        return diaries[indexPath.row]
    }

    func addDiary(diary: Diary) {
        if diaryList.isEmpty {
            diaryList = [diary]
        } else {
            diaryList.insert(diary, at: 0)
        }
        filteredDiaryList = diaryList
        creatingDiary = Diary(id: -1, title: "", date: "", mood: "", weather: "", location: "", photo: "", content: "")
    }

    func removeDiary(tittleOfToBeDeletedDiary: String) {
        let index = diaryList.index(where: {$0.title == tittleOfToBeDeletedDiary})
        if (index != nil) {
            diaryList.remove(at: index!)
        }
    }
    
    func saveDiary(diary: Diary){
        let index = diaryList.index(where: {$0.id == diary.id})
        diaryList[index!] = diary
        
        let filterDiaryIndex = filteredDiaryList.index(where: {$0.id == diary.id})
        if filterDiaryIndex != nil {
            filteredDiaryList[filterDiaryIndex!] = diary
        }
    }
    
    func saveUser(user: User){
        self.user.nickName = user.nickName
        self.user.birthDay = user.birthDay
        self.user.password = user.password
        self.user.hint = user.hint
    }
    
    func filterHomePageDiaryList(search: String, location: String, mood: String){
//        if (search.isEmpty && location.isEmpty && mood.isEmpty) {
//            filteredDiaryList = diaryList
//        }
//        else if (search.isEmpty) {
//            filteredDiaryList = diaryList.filter{ $0.location.localizedCaseInsensitiveContains(location) && $0.mood.localizedCaseInsensitiveContains(mood) }
//        }
//        else {
//            if (location.isEmpty && mood.isEmpty) {
//                filteredDiaryList = diaryList.filter{ $0.title.localizedCaseInsensitiveContains(search)}
//            } else {
//                filteredDiaryList = diaryList.filter{ $0.title.localizedCaseInsensitiveContains(search) && $0.location.localizedCaseInsensitiveContains(location) && $0.mood.localizedCaseInsensitiveContains(mood) }
//            }
//        }
        if (search.isEmpty && location.isEmpty && mood.isEmpty) {
            filteredDiaries = diaries
        }
        else if (search.isEmpty) {
            filteredDiaries = diaries.filter{ $0.location!.localizedCaseInsensitiveContains(location) && $0.mood!.localizedCaseInsensitiveContains(mood) }
        }
        else {
            if (location.isEmpty && mood.isEmpty) {
                filteredDiaries = diaries.filter{ $0.title!.localizedCaseInsensitiveContains(search)}
            } else {
                filteredDiaries = diaries.filter{ $0.title!.localizedCaseInsensitiveContains(search) && $0.location!.localizedCaseInsensitiveContains(location) && $0.mood!.localizedCaseInsensitiveContains(mood) }
            }
        }
    }
}



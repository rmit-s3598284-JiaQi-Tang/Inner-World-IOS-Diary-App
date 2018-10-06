//
//  Create_Mood_ViewController.swift
//  InnerWorld
//
//  Created by Jacky Tang on 29/8/18.
//  Copyright © 2018 Jacky Tang. All rights reserved.
//

import UIKit

class Create_Mood_ViewController: UIViewController {

    var model = Model.shared()
    var edittingDiray = Diary()

    @IBOutlet weak var moodImage: UIImageView!
    @IBOutlet weak var moodUISlider: UISlider!
    @IBAction func moodSlider(_ sender: UISlider) {
        sender.minimumValue = 0
        sender.maximumValue = 100
        var currentMood: String {
            get {
                if sender.value >= 25 && sender.value < 50 {
                    return "sad.png"
                }
                else if sender.value >= 50 && sender.value < 75 {
                    return "happy.png"
                }
                else if sender.value >= 75 {
                    return "smile.png"
                }
                else { return "cry.png" }
            }
        }
        if let image = UIImage(named:currentMood) {
            moodImage.image = image
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func forwardButtonTapped(_ sender: Any) {
        var currentMood: String {
            get {
                let val = moodUISlider.value
                print(val)
                //Slider haven't changed
                if (val == 0.5) {
                    return "happy"
                }
                if moodUISlider.value >= 25 && moodUISlider.value < 50 {
                    return "sad"
                }
                else if moodUISlider.value >= 50 && moodUISlider.value < 75 {
                    return "happy"
                }
                else if moodUISlider.value >= 75 {
                    return "smile"
                }
                else { return "cry" }
            }
        }
        model.creatingDiary.mood = currentMood
        performSegue(withIdentifier: "MoodToContentSegue", sender: nil)
    }
}

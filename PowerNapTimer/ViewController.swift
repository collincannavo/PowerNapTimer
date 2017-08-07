//
//  ViewController.swift
//  PowerNapTimer
//
//  Created by James Pacheco on 4/12/16.
//  Copyright © 2016 James Pacheco. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, TimerDelegate {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    let myTimer = MyTimer()
    
    fileprivate let userNotificationIdentifier = "timerNotification"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTimer.delegate = self
        
        setView()
    }
    
    func setView() {
        updateTimerLabel()
        // If timer is running, start button title should say "Cancel". If timer is not running, title should say "Start nap"
        if myTimer.isOn {
            startButton.setTitle("Cancel", for: UIControlState())
        } else {
            startButton.setTitle("Start nap", for: UIControlState())
        }
    }
    
    func updateTimerLabel() {
        timerLabel.text = myTimer.timeAsString()
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        if myTimer.isOn {
            myTimer.stopTimer()
            cancelLocalNotification()
        } else {
            myTimer.startTimer(10)
            scheduleLocalNotification()
            startButton.backgroundColor = UIColor.orange
        }
        setView()
    }
    
// MARK: - TimerDelegate Functions
    
    func timerStopped() {
        setView()
        startButton.backgroundColor = UIColor.green
        myTimer.timer?.invalidate()
    }
    func timerCompleted() {
        setView()
        // send an alert to user. Present AlertController
        presentIsCompletedAlert()
    }
    func timerSecondTick() {
        updateTimerLabel()
    }
    
// MARK: - How to Create an Alert Controller
    
    func presentIsCompletedAlert() {
    
        var snoozeTextField: UITextField?
        
        // 1. Create the Alert controller
        let alertController = UIAlertController(title: "Wake Up Lazy!", message: "Get Out of Bed", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            snoozeTextField = textField
            snoozeTextField?.placeholder = "How many more minutes would you like to sleep?"
            snoozeTextField?.keyboardType = .phonePad
            
        }
        
        // 2. Create Actions
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        let snoozeAction = UIAlertAction(title: "Snooze", style: .default) { (_) in
            // What happens when they click "snooze":
            
            // After the user enters the number of minutes they want to sleep, then we have to unwrap that because text is always optional. Then we can pass that number on
            guard let timeText = snoozeTextField?.text, let time = TimeInterval(timeText) else {return}
            self.scheduleLocalNotification()
            self.myTimer.startTimer(time * 60)
            self.setView()
        
        }
        
        // 3. Add Actions
        alertController.addAction(dismissAction)
        alertController.addAction(snoozeAction)
        
        
        // 4. Present Alert controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: User Notifications
    
    func scheduleLocalNotification() {
      
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Time to Wake Up!"
        notificationContent.body = "Don't sleep too late or you'll miss stuff"
       
        guard let timeRemaining = myTimer.timeRemaining else { return }
        
        let fireDate = Date(timeInterval: timeRemaining, since: Date())
        let dateComponents = Calendar.current.dateComponents([.minute, .second], from: fireDate)
        let dateTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: userNotificationIdentifier, content: notificationContent, trigger: dateTrigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Unable to add notification request. \(error.localizedDescription)")
            }
        }
        
    }
    
    func cancelLocalNotification() {
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [userNotificationIdentifier])
        
        
    }
}


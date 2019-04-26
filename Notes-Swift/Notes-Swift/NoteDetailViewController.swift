//
//  NoteDetailViewController.swift
//  Notes-Swift
//
//  Created by Aayush Maheshwari on 04/20/19.
//  Copyright (c) 2019 aayush. All rights reserved.
//

import UIKit
import MapKit
class NoteDetailViewController: UIViewController {

    let locationManager = CLLocationManager()
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    var note: Note!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleTextField.text = note.title
        contentTextField.text = note.content
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        note.title = titleTextField.text ?? ""
        note.content = contentTextField.text
        
    }
    
}

extension NoteDetailViewController : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("location:: \(location)")
            note.longitude = locations.first?.coordinate.longitude ?? 0
            note.latitude = locations.first?.coordinate.latitude ?? 0
        }
    }
    
    //    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    //        print("error:: \(error)")
    //    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

//
//  ViewController.swift
//  OVMS
//
//  Created by Nathan White on 9/15/17.
//  Copyright © 2017 Nathan White. All rights reserved.
//

import UIKit
import CoreLocation
import OBD2Swift


class ViewController: UIViewController, CLLocationManagerDelegate {
    

    @IBOutlet weak var textView: UITextView!
    
    let obd = OBD2()
   
    var ip_address = " "
    let host = "192.168.0.10"
    var port = 35000
    var server_address = " "
    var username = " "
    var password = " "
    var resultArray = [String]()
    
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect to OBD device
        obd.connect { [weak self] (success, error) in
            OperationQueue.main.addOperation({
                if let error = error {
                    print("OBD connection failed with \(error)")
                }
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendButtonAction() {
        
        getUserLocation()
        
    }
    

    func appendToTextField(string: String){
        textView.text = textView.text.appending("\n\(string)")
    }
    
    /* I need to POST GPS data and the misc. data from the OBD to an API.
     * Essentially in a loop (executed every n seconds) -> send command -> clean data -> get GPS -> send
     * as JSON to API. This collection should continue if the app is minimized(until it 
     * finishes the curent loop), but if the user presses back (to settings) it should stop.
     * When the app is minimized, save state as best as possible.
     */
    
    /* The user should be notified by pop up if the socket connection ends. Such as a car being
     * shut off.
     */
    
    /* The paragraph above should be executed on a background thread (I think). Or, the application
     * should stop collecting data when it no longer detects the device
    */
    
    /*
     * Send a flag that shows wether or not the user stopped collecting.
    */
    
    
    func getUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    /*
     * I need to pair the OBD response with this latitude, longitude data somehow.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        locationManager.stopUpdatingLocation()
        
        print(lat, long, resultArray)
        
        /*
         * Maybe POST to API from here
        */
    }
    
    
    
}


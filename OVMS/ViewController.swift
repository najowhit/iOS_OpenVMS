//
//  ViewController.swift
//  OVMS
//
//  Created by Nathan White on 9/15/17.
//  Copyright © 2017 Nathan White. All rights reserved.
//

import UIKit
import CoreLocation
import OBD2
import Alamofire



class ViewController: UIViewController, CLLocationManagerDelegate {
    

    @IBOutlet weak var textView: UITextView!
    
    // Default constructor sets (host: "192.168.0.10", port: 35000)
    let obd = OBD2()
    //let obd = OBD2(host : "192.168.0.10", port : 35000)
    
    // There is an issue with how I set up the static IP address.
    // Try setting IP to 192.168.0.11 and Subnet to 255.255.255.0
    // Leave DNS blank
    let aws_address = "http://ec2-18-216-94-71.us-east-2.compute.amazonaws.com:3000/vehicleData/"
    let dev_address = "http://localhost:3000/vehicleData/"
    var username = " "
    var password = " "
    
    var speedQueue = Queue<String>()
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
        
        // Observer for continuous speed commands
        let observer = Observer<Command.Mode01>()
        
        observer.observe(command: .pid(number: 13)) { (descriptor) in
            //let respStr = descriptor?.stringRepresentation(metric: true)
            let resp = descriptor?.valueImperial
            let respStr = String(resp!)
            print("Observer : \(String(describing: respStr))")
            
            self.speedQueue.enqueue(String(describing: respStr))
            self.getUserLocation()
        }
        
        ObserverQueue.shared.register(observer: observer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendButtonAction() {
        
        let command = Command.Mode01.pid(number: 13)
        obd.request(repeat: command)
        
        
        
        // Single test, we need to figure out what descriptor
        // gives a respStr we can work with - .stringRepresentation works
        /*obd.request(command: command) { (descriptor) in
            //let respStr = descriptor?.stringRepresentation(metric: true, rounded: false)
            let resp = descriptor?.valueImperial
            let respStr = String(resp!)
            print("TEST : \(String(describing: respStr))")
         
            self.speedQueue.enqueue(String(describing: respStr))
            self.getUserLocation()

        }*/
        
        
        
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
        
        let speed = speedQueue.peek()
        
        
        
        /*
         * Maybe POST to API from here
         */
        let parameters: Parameters = [
            "user": username,
            "speed": speed,
            "latitude": lat,
            "longitude": long
        ]
        
        
        Alamofire.request(aws_address, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { response in
            print("All Response Info: \(response)")
            
            if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
            }
        }
        
        
        speedQueue.dequeue()
    }
    
    
    
}


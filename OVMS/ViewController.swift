//
//  ViewController.swift
//  OVMS
//
//  Created by Nathan White on 9/15/17.
//  Copyright © 2017 Nathan White. All rights reserved.
//

import UIKit
import SwiftSocket
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    

    @IBOutlet weak var textView: UITextView!
    
    
    var client: TCPClient?
    var ip_address = " "
    let host = "192.168.0.10"
    var port = 35000
    var server_address = " "
    var username = " "
    var password = " "
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appendToTextField(string: ip_address)
        appendToTextField(string: String(port))
        appendToTextField(string: server_address)
        appendToTextField(string: username)
        appendToTextField(string: password)
        
        
        client = TCPClient(address: host, port: Int32(port))
        
        // Make this a method within the OBD class I will build, OBD.initialize() or 
        // OBD.connect(host, port)
        // We need to run through commands as an initialization process
        // Rough implementation, will refactor into a method
        let atArray = ["AT D\r", "AT Z\r", "AT E0\r", "AT L0\r", "AT S0\r", "AT H0\r", "AT SP 0\r"]
        
        for i in 0...atArray.count - 1{
            guard let client = client else { return }
            
            switch client.connect(timeout: 1) {
            case .success:
                appendToTextField(string: "Connected to host \(client.address)")
                
                //010C or 0105 or ATRV
                let str = atArray[i]
                let buf = [UInt8](str.utf8)
                
                if let response = sendRequest(bytesArray: buf, using: client) {
                    appendToTextField(string: "Response: \(response)")
                }
            case .failure(let error):
                appendToTextField(string: String(describing: error))
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendButtonAction() {
        guard let client = client else { return }
        
        switch client.connect(timeout: 10){
        case .success:
            appendToTextField(string: "Connected to host \(client.address)")
            
            let str = "0104\r"
            let buf = [UInt8](str.utf8)
            if let response = sendRequest(bytesArray: buf, using: client){
                appendToTextField(string: "Response: \(response)")
            }
        case .failure(let error):
            appendToTextField(string: String(describing: error))
        }
        
        getUserLocation()
    }
    
    private func sendRequest(bytesArray: [UInt8], using client: TCPClient) -> String? {
        appendToTextField(string: "Sending data ... ")
        
        switch client.send(data: Data(bytes: bytesArray)){
        case .success:
            return readResponse(from: client)
        case .failure(let error):
            appendToTextField(string: String(describing: error))
            return nil
            
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        
        // Initial fix to the issue of not reading all the data - keeps the connection open longer
        var response = [UInt8]()
        var keepGoing = true
        while keepGoing {
            guard let data = client.read(1024*10, timeout: 2) else { return nil }
            response += data
            
            // See what this does
            if data[data.count - 1] == 62 {
                print("Breaking")
                keepGoing = false
            }
        }
        
        return String(bytes: response, encoding: .utf8)
    }
    
    func appendToTextField(string: String){
        print(string)
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        locationManager.stopUpdatingLocation()
        
        print(long, lat)
    }
    
    
    
}


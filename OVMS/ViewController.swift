//
//  ViewController.swift
//  OVMS
//
//  Created by Nathan White on 9/15/17.
//  Copyright © 2017 Nathan White. All rights reserved.
//

import UIKit
import SwiftSocket

class ViewController: UIViewController {
    

    @IBOutlet weak var textView: UITextView!
    
    // Hard coded IP adress for the OBDII adapter
    
    var client: TCPClient?
    var ip_address = " "
    let host = "192.168.0.10"
    var port = 35000
    var server_address = " "
    var username = " "
    var password = " "
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(ip_address)
        print(port)
        print(server_address)
        print(username)
        print(password)
        
        client = TCPClient(address: host, port: Int32(port))
        
        /*
        // Make this a method within the OBD class I will build, OBD.initialize()
        // We need to run through commands as an initialization process
        // Rough implementation, will refactor into a method
        let atArray = ["AT D\r", "AT Z\r", "AT E0\r", "AT L0\r", "AT S0\r", "AT H0\r", "AT SP 0\r"]
        
        for i in 0...atArray.count - 1{
            guard let client = client else { return }
            
            switch client.connect(timeout: 10) {
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
            
        }*/
        
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
            
            let str = "0105\r"
            let buf = [UInt8](str.utf8)
            if let response = sendRequest(bytesArray: buf, using: client){
                appendToTextField(string: "Response: \(response)")
            }
        case .failure(let error):
            appendToTextField(string: String(describing: error))
        }
        
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
        while true {
            guard let data = client.read(1024*10, timeout: 2) else { break }
            response += data
        }
        
        return String(bytes: response, encoding: .utf8)
    }
    
    private func appendToTextField(string: String){
        print(string)
        textView.text = textView.text.appending("\n\(string)")
    }

}


//
//  SettingsViewController.swift
//  OVMS
//
//  Created by Nathan White on 9/18/17.
//  Copyright © 2017 Nathan White. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var ip_address: UITextField!
    @IBOutlet weak var port: UITextField!
    @IBOutlet weak var server_address: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        
        // We need to ensure that an IP address is not an empty string
        if ip_address.text != "" && server_address.text != "" {
            performSegue(withIdentifier: "vcSegue", sender: self)
        }
    }
    
    /*
    * Pass data through the segue
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier == "vcSegue" {
            let targetVC = segue.destination as! ViewController
        
            targetVC.ip_address = ip_address.text!
            targetVC.port = Int(port.text!) ?? 35000
            targetVC.server_address = server_address.text!
            targetVC.username = username.text!
            targetVC.password = password.text!
        }
    }
    
}

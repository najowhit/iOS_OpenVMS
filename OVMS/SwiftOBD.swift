//
//  SwiftOBD.swift
//  OVMS
//
//  Created by Nathan White on 9/21/17.
//  Copyright © 2017 Nathan White. All rights reserved.
//

import Foundation
import SwiftSocket

class SwiftOBD {
    
    var socket: TCPClient
    var client: TCPConnect
    var host: String
    var port: Int32
    
    init(host: String, port: Int32) {
        self.host = host
        self.port = port
        socket = TCPClient(address: host, port: port)
        client = TCPConnect(client: socket)
        
    }
    
    func sendCommand(command: String) -> String? {
       return client.executeConnection(command: command)
    }
    
    
    
}

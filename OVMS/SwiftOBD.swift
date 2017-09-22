//
//  SwiftOBD.swift
//  OVMS
//
//  Created by Nathan White on 9/21/17.
//  Copyright © 2017 Nathan White. All rights reserved.
//

import Foundation

class SwiftOBD {
    
    var socket: TCPConnect
    var host: String
    var port: Int32
    
    init(host: String, port: Int32) {
        self.host = host
        self.port = port
        socket = TCPConnect(address: host, port: port)
    }
    
    func sendCommand(command: String) {
        socket.executeConnection(command: command)
    }
    
    
    
}

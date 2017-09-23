//
//  TCPConnect.swift
//  OVMS
//
//  Created by Nathan White on 9/21/17.
//  Copyright © 2017 Nathan White. All rights reserved.
//

import Foundation
import SwiftSocket

class TCPConnect {
    
    let client: TCPClient?
    
    init(client: TCPClient) {
        self.client = client
    }
    
    func executeConnection(command: String) -> String? {
        guard let client = client else { return nil}
        
        var obdResponse: String?
        switch client.connect(timeout: 10){
        case .success:
            print("Connected to host \(client.address)")
            
            let buf = [UInt8](command.utf8)
            if let response = sendRequest(bytesArray: buf, using: client){
                print("Response: \(response)")
                obdResponse = response
            }
        case .failure(let error):
            print(error)
        }
        
        return obdResponse
    }
    
    private func sendRequest(bytesArray: [UInt8], using client: TCPClient) -> String? {
        
        switch client.send(data: Data(bytes: bytesArray)){
        case .success:
            return readResponse(from: client)
        case .failure(let error):
            print(error)
            return nil
            
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        
        // Initial fix to the issue of not reading all the data - keeps the connection open longer
        var response = [UInt8]()
        while true {
            guard let data = client.read(1024*10, timeout: 2) else { break }
            response += data
            
            // See what this does
            if data[data.count - 1] == 62 {
                print("Breaking")
                break
            }
        }
        
        return String(bytes: response, encoding: .utf8)
    }
    


}

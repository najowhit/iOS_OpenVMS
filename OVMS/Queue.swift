//
//  Queue.swift
//  OVMS
//
//  Created by Nathan White on 10/21/17.
//  Copyright © 2017 Nathan White. All rights reserved.
//

public struct Queue<Element>: CustomStringConvertible {
    fileprivate var head: List<Element>
    
    public var isEmpty: Bool { return head.isEmpty }
    
    public mutating func enqueue(_ x: Element) {
        head.append(x)
    }
    
    public mutating func dequeue() -> Element? {
        return head.pop()
    }
    
    public func peek() -> Element? {
        return head.peek()
    }
    
    public init() { head = .empty }
    
    public var description: String { return head.description }
}

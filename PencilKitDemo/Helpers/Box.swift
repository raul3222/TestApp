//
//  Box.swift
//  PencilKitDemo
//
//  Created by Raul Shafigin on 13.09.2024.
//

import Foundation

class Box<T> {
    typealias Listener = (T) -> Void
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    var listener: Listener?
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: @escaping Listener) {
        listener(value)
        self.listener = listener
    }
}

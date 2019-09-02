//
//  Atomic.swift
//  Swift Atomic
//
//  Created by Ben Leggiero for the RougeWare Project on 2019-08-28
//  Copyright © 2019 Ben Leggiero BH-1-PS
//  https://GitHub.com/BlueHuskyStudios/Licenses/tree/master/Licenses/BH-1-PS.txt
//

import Foundation
import Dispatch



/// Uses a dedicated dispatch queue to guarantee the wrapped value is only ever accessed from one thread at a time
@propertyWrapper
public struct Atomic<WrappedValue> {
    
    /// The value which should only be read from one thread at a time
    private var threadUnsafeValue: WrappedValue
    
    /// The queue which will ensure only one thread will be able to read the value at a time
    private var exclusiveAccessQueue: DispatchQueue
    
    /// Safely accesses the unsafe value from within the context of its exclusive-access queue
    public var wrappedValue: WrappedValue {
        get { exclusiveAccessQueue.sync { threadUnsafeValue } }
        set { exclusiveAccessQueue.sync { threadUnsafeValue = newValue } }
    }
    
    
    /// Creates a new `Atomic` property wrapper
    ///
    /// - Attention: This initializer allows you to specify a queue for exclusive access. **This queue must never be
    ///              used to access this property wrapper instance!** If that happens, the threads _will_ deadlock.
    ///
    /// - Parameters:
    ///   - wrappedValue: The value which should only be read from one thread at a time
    ///   - queue:        _optional_ The queue which will ensure only one thread will be able to read the value at a
    ///                   time. Defaults to a dedicated, guaranteed-safe queue.
    public init(wrappedValue: WrappedValue, queue: DispatchQueue = .newAtomicDispatchQueue()) {
        self.threadUnsafeValue = wrappedValue
        self.exclusiveAccessQueue = queue
    }
}



public extension DispatchQueue {
    /// Creates a new dispatch queue suitable for acting as an exclusive accessor for a particular value
    static func newAtomicDispatchQueue() -> DispatchQueue {
        return DispatchQueue(label: "Exclusive Atomic value accessor \(UUID())", qos: .userInteractive)
    }
}

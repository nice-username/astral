//
//  ObjectPool.swift
//  astral
//
//  Created by Joseph Haygood on 2/12/25.
//

import Foundation

/// Generic Object Pool for reusing game objects
class ObjectPool<T: AnyObject> {
    private var objects: [T] = []
    private let factory: () -> T
    private let reset: (T) -> Void
    private let maxPoolSize: Int

    init(factory: @escaping () -> T, reset: @escaping (T) -> Void, maxPoolSize: Int = 100) {
        self.factory = factory
        self.reset = reset
        self.maxPoolSize = maxPoolSize
    }

    func obtain() -> T {
        if let object = objects.popLast() {
            reset(object)  // Reset before reuse
            return object
        }
        return factory()
    }

    func recycle(_ object: T) {
        guard objects.count < maxPoolSize else { return }
        objects.append(object)
    }
    
    /// Preallocate objects in advance
    func preallocate(_ count: Int) {
        for _ in 0..<min(count, maxPoolSize) {
            objects.append(factory())
        }
    }
}

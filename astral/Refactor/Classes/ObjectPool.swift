//
//  ObjectPool.swift
//  astral
//
//  Created by Joseph Haygood on 2/12/25.
//

import Foundation

/// Generic Object Pool for reusing game objects, optimized for ECS
class ObjectPool<T: AnyObject> {
    private var available: [T] = []
    private var inUse: Set<ObjectIdentifier> = []
    private let factory: () -> T
    private let reset: (T) -> Void
    private let maxPoolSize: Int
    
    // Statistics for debugging
    private(set) var totalCreated: Int = 0
    private(set) var totalRecycled: Int = 0
    private(set) var peakUsage: Int = 0

    init(factory: @escaping () -> T, reset: @escaping (T) -> Void, maxPoolSize: Int = 100) {
        self.factory = factory
        self.reset = reset
        self.maxPoolSize = maxPoolSize
    }

    func obtain() -> T {
        let object: T
        
        if let pooledObject = available.popLast() {
            object = pooledObject
            totalRecycled += 1
        } else {
            object = factory()
            totalCreated += 1
        }
        
        // Track object as in use
        let id = ObjectIdentifier(object)
        inUse.insert(id)
        
        // Update peak usage statistics
        peakUsage = max(peakUsage, inUse.count)
        
        // Reset the object before returning
        reset(object)
        return object
    }

    func recycle(_ object: T) {
        let id = ObjectIdentifier(object)
        
        // Only recycle if we were tracking this object
        guard inUse.remove(id) != nil else {
            print("Warning: Attempting to recycle object not obtained from this pool")
            return
        }
        
        // Only keep object if we have space
        guard available.count < maxPoolSize else { 
            print("Pool full, discarding object (pool size: \(maxPoolSize))")
            return 
        }
        
        available.append(object)
    }
    
    /// Preallocate objects in advance
    func preallocate(_ count: Int) {
        let toCreate = min(count, maxPoolSize - available.count)
        for _ in 0..<toCreate {
            available.append(factory())
            totalCreated += 1
        }
    }
    
    /// Get current pool statistics
    func getStatistics() -> PoolStatistics {
        return PoolStatistics(
            available: available.count,
            inUse: inUse.count,
            totalCreated: totalCreated,
            totalRecycled: totalRecycled,
            peakUsage: peakUsage,
            maxSize: maxPoolSize
        )
    }
    
    /// Clear all pooled objects (useful for memory management)
    func clear() {
        available.removeAll()
        inUse.removeAll()
    }
    
    /// Validate pool integrity (debug function)
    func validateIntegrity() -> Bool {
        let totalTracked = available.count + inUse.count
        let isValid = totalTracked <= maxPoolSize
        
        if !isValid {
            print("Pool integrity check failed: \(totalTracked) objects tracked, max: \(maxPoolSize)")
        }
        
        return isValid
    }
}

/// Statistics structure for object pools
struct PoolStatistics {
    let available: Int
    let inUse: Int
    let totalCreated: Int
    let totalRecycled: Int
    let peakUsage: Int
    let maxSize: Int
    
    var recycleRate: Float {
        guard totalCreated > 0 else { return 0 }
        return Float(totalRecycled) / Float(totalCreated)
    }
    
    var utilizationRate: Float {
        return Float(inUse) / Float(maxSize)
    }
}

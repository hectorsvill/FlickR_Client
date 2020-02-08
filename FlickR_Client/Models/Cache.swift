//
//  Cache.swift
//  FlickR_Client
//
//  Created by s on 2/8/20.
//  Copyright © 2020 s. All rights reserved.
//

import Foundation

class Cache <Key: Hashable, Value> {
    let queue = DispatchQueue(label: "Cache DispatchQueue")
    private var cache: [Key: Value] = [:]

    func cache(value: Value, for key: Key) {
        queue.sync {
            if let _ = cache[key] { return }
            cache[key] = value
        }
    }

    func value(for key: Key) -> Value? {
        return queue.sync { cache[key] }
    }
}

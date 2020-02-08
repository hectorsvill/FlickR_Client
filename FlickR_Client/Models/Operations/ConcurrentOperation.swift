//
//  ConcurrentOperation.swift
//  FlickR_Client
//
//  Created by s on 2/8/20.
//  Copyright © 2020 s. All rights reserved.
//

import Foundation

class ConcurrentOperation: Operation {
    private let stateQueue = DispatchQueue(label: "com.hectorstevenvillasano.andIQuote.FlickR-Client.ConcuttentOperationQueue")

    enum State: String {
        case isReady, isExecuting, isFinished
    }

    private var _state = State.isReady

    var state: State {
        get {
            var result: State?
            let queue = self.stateQueue
            queue.sync {
                result = _state
            }
            return result!
        }

        set {
            let oldValue = state
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: oldValue.rawValue)

            stateQueue.sync { self._state = newValue }

            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: newValue.rawValue)
        }
    }

    // MARK: NSOperation

    override dynamic var isReady: Bool {
        super.isReady && state == .isReady
    }

    override dynamic var isExecuting: Bool {
        state == .isExecuting
    }

    override dynamic var isFinished: Bool {
        state == .isFinished
    }

    override var isAsynchronous: Bool {
        true
    }
}

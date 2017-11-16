//
// Copyright 2017 Ali Akhtarzada
//
// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

extension Task {
    public func await(
        with taskManager: TaskManager? = nil,
        queue _: DispatchQueue? = nil,
        timeout: DispatchTimeInterval? = nil
    ) throws -> SuccessValue {
        let semaphore = DispatchSemaphore(value: 0)
        var maybeResult: TaskResult?
        (taskManager ?? TaskManager.shared).add(
            task: self,
            startImmediately: true
        ) { result in
            maybeResult = result
            semaphore.signal()
        }
        if let timeout = timeout, semaphore.wait(timeout: .now() + timeout) == .timedOut {
            throw TaskError.timedOut
        } else {
            semaphore.wait()
        }
        guard let result = maybeResult else {
            throw TaskError.unknown
        }
        switch result {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }
}
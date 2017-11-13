/*
 Copyright 2017 Ali Akhtarzada

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

public class AnyTask<T>: Task {

    public typealias SuccessValue = T

    var executeThunk: (@escaping ResultCallback) -> Void
    // TODO: remove internalTask if its only purpose is testing
    var internalTask: AnyObject?

    public init(timeout: DispatchTimeInterval? = nil, execute: (@escaping (@escaping ResultCallback) -> Void)) {
        self.executeThunk = { completion in
            execute { result in
                completion(result)
            }
        }
        self.timeout = timeout
    }

    public convenience init(timeout: DispatchTimeInterval? = nil, execute: @escaping () -> Result<T>) {
        self.init(timeout: timeout) { completion in
            completion(execute())
        }
    }

    public convenience init(timeout: DispatchTimeInterval? = nil, execute: @escaping () -> T) {
        self.init(timeout: timeout) { completion in
            completion(.success(execute()))
        }
    }

    public init<U: Task>(_ task: U) where U.SuccessValue == SuccessValue {
        self.executeThunk = { completion in
            task.execute { result in
                completion(result)
            }
        }
        self.timeout = task.timeout
        self.internalTask = task
    }

    public var timeout: DispatchTimeInterval?

    public func execute(completion: @escaping ResultCallback) {
        self.executeThunk(completion)
    }
}

extension AnyTask where T == Any {
    public convenience init<U: Task>(_ task: U) {
        self.init(timeout: task.timeout) { completion in
            task.execute { result in
                completion(AnyResult(result))
            }
        }
        self.internalTask = task
    }
}


//
// Copyright 2017 Ali Akhtarzada
//
// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//

import Quick
import Nimble
import Mockingjay

@testable import Swooft

private class Interceptor: TaskInterceptor {
    func intercept<T>(task: inout T, currentBatchCount _: Int) -> InterceptCommand where T: Task {
        guard let task = task as? URLInterceptor.DataTask else {
            return .execute
        }
        task.request.addValue("hahaha", forHTTPHeaderField: "hahaha")
        return .execute
    }
}

private class Reactor: TaskReactor {
    func execute(done: @escaping (Error?) -> Void) {
        done(nil)
    }

    func shouldExecute<T: Task>(after result: T.TaskResult, from task: T, with _: TaskHandle) -> Bool {
        guard let result = result as? URLInterceptor.DataTask.TaskResult else {
            return false
        }
        if case .success(let tuple) = result {
            return (tuple.1 as? HTTPURLResponse)?.statusCode == 200
        }
        return false
    }

    var configuration: TaskReactorConfiguration {
        return TaskReactorConfiguration(
            isImmediate: true,
            timeout: nil,
            requeuesTask: true,
            suspendsTaskQueue: false
        )
    }
}

extension Data {
    func string() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

extension XCTest {
    @discardableResult
    public func stub(_ matcher: @escaping Mockingjay.Matcher, delay: TimeInterval? = nil, _ builders: [(URLRequest) -> Response]) -> Stub {
        let max = builders.count
        var count = 0
        return self.stub(matcher, delay: delay, { request -> Response in
            let builder = builders[count]
            if count < max - 1 {
                count += 1
            }
            return builder(request)
        })
    }
}

class URLInterceptorTests: QuickSpec {

    override func spec() {

        describe("test") {
            it("should") {
                func matcher(request: URLRequest) -> Bool {
                    return request.allHTTPHeaderFields?["hahaha"]?.contains("hahaha") ?? false
                }
                self.stub(matcher, [
                    jsonData("yodles".data(using: .utf8)!),
                    http(400)]
                )
                let urlInterceptor = URLInterceptor(interceptors: [Interceptor()], reactors: [Reactor()], configuration: .default)
                let task = urlInterceptor.session.dataTask(with: URL(string: "http://www.msftncsi.com/ncsi.txt")!) { data, response, error in
                    print("# 1", data!.string()!)
                    print("# 2", response as Any)
                    print("# 3", error as Any)
                }
                task.resume()
//                task.cancel()

                ensure(task.state.rawValue).becomes(URLSessionTask.State.completed.rawValue)
            }
        }
    }
}

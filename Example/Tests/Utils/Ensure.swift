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
import Quick

/*
 These are here because of me thinks a bug inside expect(blah).toEventually(blah), or not
 a bug but something related to caching or memoization

 If you run the following code then DEINIT will never be printed and if you change the
 toEventually to just 'to' then it will print as expected.

 ```
 class Test {
     let i = 5
     init() {
         print("INIT")
     }
     deinit {
         print("DEINIT")
     }
 }

 class TestTests: QuickSpec {
     override func spec() {
         it("testing eventually") {
             let test = Test()
             expect(test.i).toEventually(equal(5))
         }
     }
 }

 ```
 */

struct Ensure<T: Equatable> {
    let block: () -> T
    let line: UInt
    let file: StaticString

    init(block: @escaping () -> T, line: UInt, file: StaticString) {
        self.block = block
        self.line = line
        self.file = file
    }

    func becomes(_ value: T) {
        var lastValue = self.block()
        var passed = lastValue == value
        let start = Date()
        while Date().timeIntervalSince(start) < 1 && !passed {
            sleep(for: .milliseconds(1))
            lastValue = self.block()
            passed = lastValue == value
        }
        if !passed {
            XCTFail("expected \(value), got \(lastValue)", file: self.file, line: self.line)
        }
    }

    func doesNotBecome(_ value: T, for seconds: Double = 0.1) {
        var passed = false
        var changed = false
        let start = Date()
        while Date().timeIntervalSince(start) < seconds || changed {
            sleep(for: .milliseconds(1))
            let previousPassed = passed
            passed = self.block() == value
            changed = previousPassed != passed
        }
        if self.block() == value {
            XCTFail("did not expect \(value)", file: self.file, line: self.line)
        }
    }

    func stays(_ value: T, for seconds: Double = 0.1) {
        var lastValue = self.block()
        var passed = lastValue == value
        let start = Date()
        while Date().timeIntervalSince(start) < seconds && passed {
            sleep(for: .milliseconds(1))
            lastValue = self.block()
            passed = lastValue == value
        }
        if lastValue != value {
            XCTFail("expected to remain \(value), but became \(lastValue)", file: self.file, line: self.line)
        }
    }
}

func ensure<T: Equatable>(_ block: @escaping @autoclosure () -> T, _ line: UInt = #line, _ file: StaticString = #file) -> Ensure<T> {
    return Ensure(block: block, line: line, file: file)
}

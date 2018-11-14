//
// Copyright 2017 Ali Akhtarzada
//
// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//

import XCTest
@testable import Tasker

final class AsyncAwaitTests: XCTestCase {
    func testShouldWork() {
        let task = AsyncAwaitSpy { () -> Int in
            let one = try! TaskSpy<Int> { callback in
                sleep(for: .milliseconds(1))
                callback(.success(1))
            }.await()
            let two = try! TaskSpy<Int> { callback in
                sleep(for: .milliseconds(1))
                callback(.success(2))
            }.await()
            return one + two
        }
        task.async()
        ensure(task.completionCallCount).becomes(1)
        ensure(task.completionCallData.first!.successValue).becomes(3)
    }

    func testAsyncShouldCallExecute() {
        let task = AsyncAwaitSpy {}
        task.async()
        ensure(task.completionCallCount).becomes(1)
    }

    func testAsyncShouldGetCancelledError() {
        let task = AsyncAwaitSpy { sleep(for: .milliseconds(5)) }
        let handle = task.async()
        handle.cancel()
        ensure(task.completionCallCount).becomes(1)
        XCTAssertEqual(task.completionCallData[0].failureValue! as NSError, TaskError.cancelled as NSError)
    }

    func testAsyncShouldTimeoutAfterDeadline() {
        let task = AsyncAwaitSpy { sleep(for: .milliseconds(5)) }
        let handle = task.async(timeout: .milliseconds(1))
        ensure(task.completionCallCount).becomes(1)
        XCTAssertEqual(task.completionCallData[0].failureValue! as NSError, TaskError.timedOut as NSError)
        ensure(handle.state).becomes(.finished)
    }

    func testAsyncShouldCallCompletionOnSpecifiedQueue() {
        let queue = DispatchQueue(label: "Swooft.Tests.AsyncTask")
        let key = DispatchSpecificKey<Void>()
        queue.setSpecific(key: key, value: ())
        let task = AsyncAwaitSpy {}
        task.async(queue: queue) { _ in
            XCTAssertTrue(DispatchQueue.getSpecific(key: key) != nil)
        }
        ensure(task.completionCallCount).becomes(1)
    }

    func testAwaitShouldReturnValue() {
        let task = AsyncAwaitSpy { true }
        let value = try! task.await()
        XCTAssertTrue(value)
        ensure(task.completionCallCount).stays(1)
    }

    func testAwaitShouldTurnAsyncIntoSync() {
        let task = AsyncAwaitSpy { () -> Int in
            sleep(for: .milliseconds(1))
            return 3
        }
        let value = try! task.await()
        XCTAssertEqual(value, 3)
        ensure(task.completionCallCount).stays(1)
    }

    func testAwaitShouldTimeoutAfterDeadline() {
        let task = AsyncAwaitSpy { sleep(for: .milliseconds(5)) }
        var maybeError: Error?
        do {
            try task.await(timeout: .milliseconds(1))
        } catch {
            maybeError = error
        }
        XCTAssertEqual(maybeError! as NSError, TaskError.timedOut as NSError)
        ensure(task.completionCallCount).stays(1)
    }

    // func testAwaitShouldCallCompletionOnSpecifiedQueue() {
    //     let queue = DispatchQueue(label: "Swooft.Tests.AsyncTask")
    //     let key = DispatchSpecificKey<Void>()
    //     queue.setSpecific(key: key, value: ())
    //     let task = AsyncTaskSpy {
    //         expect(DispatchQueue.getSpecific(key: key)).toNot(beNil())
    //     }
    //     _ = try! task.await(queue: queue)
    // }
}
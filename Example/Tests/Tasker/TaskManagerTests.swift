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

@testable import Swooft

private extension TaskManagerSpy {
    @discardableResult
    func launch<T: Task>(task: @autoclosure () -> T, count: Int) -> (handles: [TaskHandle], tasks: [T]) {
        var handles: [TaskHandle] = []
        var tasks: [T] = []
        for _ in 0..<count {
            let task = task()
            handles.append(self.add(task: task))
            tasks.append(task)
        }
        return (handles, tasks)
    }
}

class TaskManagerTests: QuickSpec {

    override func spec() {

        describe("Adding a task") {

            it("should execute it") {
                let manager = TaskManagerSpy()
                let task = TaskSpy { $0(.success(())) }
                manager.add(task: task)
                ensure(task.executeCallCount).becomes(1)
            }

            it("should call completion callback") {
                let manager = TaskManagerSpy()
                manager.add(task: kDummyTask)
                ensure(manager.completionCallCount).becomes(1)
            }

            it("should not execute if not told to") {
                let manager = TaskManagerSpy()
                let handle = manager.add(task: kDummyTask, startImmediately: false)
                ensure(handle.state).stays(.pending)
            }

            it("should call completion callback after given interval") {
                let manager = TaskManagerSpy()
                let interval: DispatchTimeInterval = .milliseconds(20)
                let shouldStartAfter: DispatchTime = .now() + interval
                var didStartAfter: DispatchTime!
                let task = TaskSpy<Void> { cb in
                    didStartAfter = .now()
                    cb(.success(()))
                }

                manager.add(task: task, after: interval)
                ensure(manager.completionCallCount).becomes(1)
                expect(didStartAfter) > shouldStartAfter
            }
        }

        describe("adding many tasks") {

            it("should call all callbacks") {
                let manager = TaskManagerSpy()
                manager.launch(task: TaskSpy { $0(.success(())) }, count: 100)
                ensure(manager.completionCallCount).becomes(100)
            }

            it("should execute all tasks") {
                let manager = TaskManagerSpy()
                let (_, tasks) = manager.launch(task: TaskSpy { $0(.success(())) }, count: 100)
                for task in tasks {
                    ensure(task.executeCallCount).becomes(1)
                }
            }

            it("should make all handles finished") {
                let manager = TaskManagerSpy()
                let (handles, _) = manager.launch(task: TaskSpy { $0(.success(())) }, count: 100)
                for handle in handles {
                    ensure(handle.state).becomes(TaskState.finished)
                }
            }
        }
    }
}

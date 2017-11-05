//
//  TaskReactor.swift
//  Swooft
//
//  Created by Ali Akhtarzada on 11/2/17.
//

import Foundation

/**
 A task reactor allows you to control what the task manager should after a task is completed
 */
public protocol TaskReactor {
    /**
     Return true if you want this interceptor to be executed

     - parameter after: the result of the task that was just executed
     - parameter from: the actual task that was just executed
     - parameter with: the handle to the task that was just executed
     */
    func shouldExecute<T: Task>(after: T.TaskResult, from: T, with: TaskHandle) -> Bool

    /**
     Does the interceptor work
     */
    func execute(done: @escaping (Error?) -> Void)

    /**
     The configuration that this interceptor has
     */
    var configuration: TaskReactorConfiguration { get }
}

extension TaskReactor {
    func execute(done: @escaping (Error?) -> Void) {
        done(nil)
    }

    func shouldExecute<T: Task>(after _: T.TaskResult, from _: T, with _: TaskHandle) -> Bool {
        return false
    }

    var configuration: TaskReactorConfiguration {
        return .default
    }
}

import Foundation
@testable import Tasker

var kTaskSpyCounter = AtomicInt()

class TaskSpy<T>: AnyTask<T> {
    var executeCallCount: Int {
        self.executeCallBackData.count
    }

    var executeCallBackData: SynchronizedArray<AnyResult> = []

    override init(timeout: DispatchTimeInterval? = nil, execute: @escaping (@escaping CompletionCallback) -> Void) {
        super.init(timeout: timeout, execute: execute)
        kTaskSpyCounter.getAndIncrement()
    }

    convenience init(timeout: DispatchTimeInterval? = nil, execute: @escaping () -> TaskSpy.Result) {
        self.init(timeout: timeout) { completion in
            completion(execute())
        }
    }

    convenience init(timeout: DispatchTimeInterval? = nil, execute: @escaping () -> T) {
        self.init(timeout: timeout) { completion in
            completion(.success(execute()))
        }
    }

    // TODO: Uncomment when bug fixed: https://bugs.swift.org/browse/SR-8142
//    convenience init<U: Task>(_ task: U) where U.SuccessValue == SuccessValue {
//        self.init(timeout: task.timeout) { completion in
//            task.execute(completion: completion)
//        }
//    }

    deinit {
        kTaskSpyCounter.getAndDecrement()
    }

    override func execute(completion: @escaping CompletionCallback) {
        let wrappedCompletion: CompletionCallback = { [weak self] result in
            self?.executeCallBackData.append(AnyResult(result))
            completion(result)
        }
        self.executeThunk(wrappedCompletion)
    }
}

import Foundation

extension TaskManager.Handle {
    // TODO: make this a value type?
    class Data {
        typealias InterceptionCallback = (@escaping (InterceptorManager.InterceptionResult) -> Void) -> Void

        var operation: AsyncOperation
        let taskReference: AnyObject
        let completionErrorCallback: (TaskError) -> Void
        let taskDidCancelCallback: (TaskError) -> Void
        let interceptionCallback: InterceptionCallback
        let completionQueue: DispatchQueue?
        var state: TaskState = .pending

        init(
            operation: AsyncOperation,
            taskReference: AnyObject,
            completionErrorCallback: @escaping (TaskError) -> Void,
            taskDidCancelCallback: @escaping (TaskError) -> Void,
            interceptionCallback: @escaping InterceptionCallback,
            completionQueue: DispatchQueue?
        ) {
            self.operation = operation
            self.taskReference = taskReference
            self.completionErrorCallback = completionErrorCallback
            self.taskDidCancelCallback = taskDidCancelCallback
            self.interceptionCallback = interceptionCallback
            self.completionQueue = completionQueue
        }
    }
}

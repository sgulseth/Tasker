import Foundation
import Tasker

class AsyncAwaitSpy<T>: TaskSpy<T> {
    var completionCallCount: Int {
        return self.completionCallData.count
    }

    var completionCallData: [Result<T>] = []

    convenience init(timeout: DispatchTimeInterval? = nil, execute: @escaping () -> Result<T>) {
        self.init(timeout: timeout) { completion in
            completion(execute())
        }
    }

    convenience init(timeout: DispatchTimeInterval? = nil, execute: @escaping () -> T) {
        self.init(timeout: timeout) { completion in
            completion(.success(execute()))
        }
    }

    @discardableResult
    func async(
        after interval: DispatchTimeInterval? = nil,
        queue: DispatchQueue? = nil,
        timeout: DispatchTimeInterval? = nil,
        completion: ((Result<T>) -> Void)? = nil
    ) -> TaskHandle {
        return super.async(with: nil, after: interval, queue: queue, timeout: timeout) { [weak self] result in
            defer {
                self?.completionCallData.append(result)
            }
            completion?(result)
        }
    }

    @discardableResult
    func await(queue: DispatchQueue? = nil, timeout: DispatchTimeInterval? = nil) throws -> T {
        do {
            let value = try super.await(queue: queue, timeout: timeout)
            self.completionCallData.append(.success(value))
            return value
        } catch {
            self.completionCallData.append(.failure(error))
            throw error
        }
    }
}

//
//  _.swift
//  MovieExplorer
//
//  Created by syed tanveer hussain on 26/02/2026.
//

import Foundation

@MainActor
final class BackgroundJob<Output> {
    enum JobError: Error {
        case notStarted
    }

    private var task: Task<Output, Error>?

    deinit {
        task?.cancel()
    }

    func start(
        priority: TaskPriority = .utility,
        _ operation: @escaping @Sendable () async throws -> Output
    ){
        task?.cancel() // cancel previous run
        task = Task.detached(priority: priority) {
            try await operation()
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }

    func value() async throws -> Output {
        guard let task else { throw JobError.notStarted }
        defer { self.task = nil }
        return try await task.value
    }

    var isRunning: Bool {
        task != nil && !(task?.isCancelled ?? true)
    }
}



//let job = BackgroundJob<Int>()

//job.start {
//    var total = 0
//    for i in 1...5_000_000 {
//        if i % 10_000 == 0 { try Task.checkCancellation() } // cooperative cancel
//        total += i
//    }
//    return total
//}
//
//Task {
//    do {
//        let result = try await job.value()
//        print("Done:", result)
//    } catch is CancellationError {
//        print("Cancelled")
//    } catch {
//        print("Failed:", error)
//    }
//}
//
//// Later
//job.cancel()

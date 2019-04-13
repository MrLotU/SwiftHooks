import Foundation

public typealias EventClosure = (Event, Data) throws -> Void

public protocol Event {
    func getData<T>(_ type: T.Type, from: Data) -> T?
}

public protocol Userable: Hashable {
    associatedtype ID: Hashable
    var id: ID { get }
    
    var mention: String { get }
}

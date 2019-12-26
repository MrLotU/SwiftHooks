public protocol Userable: PayloadType {
    var identifier: String? { get }
    var mention: String { get }
}

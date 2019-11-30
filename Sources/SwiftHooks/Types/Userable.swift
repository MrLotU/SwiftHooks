public protocol Userable: PayloadType {
    var id: IDable { get }
    var mention: String { get }
}

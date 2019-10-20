public protocol Userable: Codable {
    var id: IDable { get }
    
    var mention: String { get }
}

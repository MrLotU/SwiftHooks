/// A generic user used in `GlobalEvent`s.
public protocol Userable: PayloadType {
    /// Identifier of the user. Should be platform unique.
    var identifier: String? { get }
    
    /// String that will mention the user when sent. For example `@username` or `<@userid>`
    var mention: String { get }
}

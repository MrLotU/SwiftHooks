public protocol Channelable: Codable {
    func send(_ msg: String)
    
    var mention: String { get }
}

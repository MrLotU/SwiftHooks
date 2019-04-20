public protocol Channelable {
    func send(_ msg: String)
    
    var mention: String { get }
}

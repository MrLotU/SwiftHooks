public protocol Hook {
    func connect() throws
    func shutDown() throws
}

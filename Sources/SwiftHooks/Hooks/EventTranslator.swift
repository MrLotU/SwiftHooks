public protocol EventTranslator: class {
    func translate<E>(_ event: E) -> GlobalEvent? where E: EventType
}

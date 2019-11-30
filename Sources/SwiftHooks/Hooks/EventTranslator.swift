import struct Foundation.Data
public protocol EventTranslator: class {
    static func translate<E>(_ event: E) -> GlobalEvent? where E: EventType
    static func decodeConcreteType<T>(for event: GlobalEvent, with data: Data, as t: T.Type) -> T?
//    static func decodableTypeForEvent<E, T>(_ event: E) -> T.Type? where E: EventType, T: Decodable
}

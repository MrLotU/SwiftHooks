import struct Foundation.UUID

public protocol CommandArgumentConvertible {
    associatedtype ResolvedArgument = Self
    
    static var typedName: String { get }
    static func resolveArgument(_ argument: String, on event: CommandEvent) throws -> ResolvedArgument
    static func resolveArgument(_ argument: String?, arg: CommandArgument, on event: CommandEvent) throws -> ResolvedArgument
}

public protocol ConsumingCommandArgumentConvertible: CommandArgumentConvertible, AnyConsuming { }

public protocol CommandArgument {
    var isOptional: Bool { get }
    var isConsuming: Bool { get }
    var componentType: String { get }
    var componentName: String { get }
}

func == (_ lhs: CommandArgument, _ rhs: CommandArgument) -> Bool {
    return lhs.description == rhs.description
}

extension CommandArgument {
    public var description: String {
        let compType = self.isConsuming ? "\(componentType)..." : componentType
        if self.isOptional {
            return "[\(componentName):\(compType)]"
        } else {
            return "<\(componentName):\(compType)>"
        }
    }
}


public protocol AnyConsuming {}
protocol AnyOptionalType {
    var isNil: Bool { get }
    static func resolveNil() -> Any?
}
extension Optional: AnyOptionalType {
    var isNil: Bool { self == nil }
    static func resolveNil() -> Any? { return nil }
}

struct GenericCommandArgument<T: CommandArgumentConvertible>: CommandArgument {
    let componentType: String
    let componentName: String
    
    var isOptional: Bool {
        T.self is AnyOptionalType.Type
    }
    
    var isConsuming: Bool {
        T.self is AnyConsuming.Type
    }
}

extension CommandArgumentConvertible {
    public static var typedName: String {
        return "\(Self.self)"
    }
    
    public static func resolveArgument(_ argument: String?, arg: CommandArgument, on event: CommandEvent) throws -> Self.ResolvedArgument {
        guard let argument = argument else {
            throw CommandError.ArgumentNotFound(arg.componentName)
        }
        return try self.resolveArgument(argument, on: event)
    }
}

extension String: CommandArgumentConvertible {
    public static func resolveArgument(_ argument: String, on event: CommandEvent) throws -> String {
        return argument
    }
}

public extension String {
    struct Consuming: ConsumingCommandArgumentConvertible {
        public static var typedName: String {
            String.typedName
        }
        public typealias ResolvedArgument = String
        public static func resolveArgument(_ argument: String, on event: CommandEvent) throws -> String {
            return argument
        }
    }
}

extension FixedWidthInteger {
    public static func resolveArgument(_ argument: String, on event: CommandEvent) throws -> Self {
        guard let number = Self(argument) else {
            throw CommandError.UnableToConvertArgument(argument, "\(self.self)")
        }
        return number
    }
}

extension Int: CommandArgumentConvertible { }
extension Int8: CommandArgumentConvertible { }
extension Int16: CommandArgumentConvertible { }
extension Int32: CommandArgumentConvertible { }
extension Int64: CommandArgumentConvertible { }
extension UInt: CommandArgumentConvertible { }
extension UInt8: CommandArgumentConvertible { }
extension UInt16: CommandArgumentConvertible { }
extension UInt32: CommandArgumentConvertible { }
extension UInt64: CommandArgumentConvertible { }

extension BinaryFloatingPoint {
    public static func resolveArgument(_ argument: String, on event: CommandEvent) throws -> Self {
        guard let number = Double(argument) else {
            throw CommandError.UnableToConvertArgument(argument, "\(self.self)")
        }
        return Self(number)
    }
}


extension Float: CommandArgumentConvertible { }
extension Double: CommandArgumentConvertible { }

extension UUID: CommandArgumentConvertible {
    public static func resolveArgument(_ argument: String, on event: CommandEvent) throws -> UUID {
        guard let uuid = UUID(uuidString: argument) else {
            throw CommandError.UnableToConvertArgument(argument, "\(self.self)")
        }
        return uuid
    }
}

extension Array: ConsumingCommandArgumentConvertible, CommandArgumentConvertible, AnyConsuming where Element: CommandArgumentConvertible {
    public typealias ResolvedArgument = [Element.ResolvedArgument]
    
    public static var typedName: String {
        return "\(Element.typedName)"
    }
    
    public static func resolveArgument(_ argument: String, on event: CommandEvent) throws -> ResolvedArgument {
        let args = argument.split(separator: " ").map(String.init)
        return try args.reduce(into: [], { $0.append(try Element.resolveArgument($1, on: event)) })
    }
}

extension Optional: CommandArgumentConvertible where Wrapped: CommandArgumentConvertible {
    public static var typedName: String {
        Wrapped.typedName
    }
    public typealias ResolvedArgument = Wrapped.ResolvedArgument?
    public static func resolveArgument(_ argument: String, on event: CommandEvent) throws -> Wrapped.ResolvedArgument? {
        guard !argument.isEmpty else { return nil }
        return try? Wrapped.resolveArgument(argument, on: event)
    }
    
    public static func resolveArgument(_ argument: String?, arg: CommandArgument, on event: CommandEvent) throws -> ResolvedArgument {
        if let arg = argument {
            return try self.resolveArgument(arg, on: event)
        } else {
            return nil
        }
    }
}

extension Optional: ConsumingCommandArgumentConvertible, AnyConsuming where Wrapped: ConsumingCommandArgumentConvertible { }

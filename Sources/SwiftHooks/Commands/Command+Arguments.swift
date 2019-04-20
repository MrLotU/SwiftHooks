import Foundation

public protocol CommandArgumentConvertible {
    associatedtype ResolvedArgument = Self
    
    static var typedName: String { get }
    static var canConsume: Bool { get }
    static func resolveArgument(_ argument: String, on event: CommandEvent) throws -> ResolvedArgument
}

extension CommandArgumentConvertible {
    public static var typedName: String {
        return "\(Self.self)"
    }
    
    public static var canConsume: Bool {
        return false
    }
    
    public static func argument(named name: String, argType: CommandArgumentType = .required) throws -> CommandArgument {
        if argType.consumes && !self.canConsume {
            throw CommandError.ArgumentCanNotConsume
        }
        return CommandArgument(componentType: self.typedName, componentName: name, type: argType)
    }
}

public enum CommandArgumentType {
    case required, requiredConsume
    case optional, optionalConsume
    
    var consumes: Bool {
        return [.requiredConsume, .optionalConsume].contains(self)
    }
    
    var optional: Bool {
        return [.optional, .optionalConsume].contains(self)
    }
}

public struct CommandArgument: CustomStringConvertible, Equatable {
    let componentType: String
    let componentName: String
    
    var type: CommandArgumentType
    
    public var description: String {
        let compType = self.type.consumes ? "\(componentType)..." : componentType
        if self.type.optional {
            return "[\(componentName):\(compType)]"
        } else {
            return "<\(componentName):\(compType)>"
        }
    }
}

extension String: CommandArgumentConvertible {
    public static func resolveArgument(_ argument: String, on event: CommandEvent) throws -> String {
        return argument
    }
    
    public static var canConsume: Bool {
        return true
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

extension Array: CommandArgumentConvertible where Element: CommandArgumentConvertible {
    public typealias ResolvedArgument = [Element.ResolvedArgument]
    
    public static var typedName: String {
        return "\(Element.typedName)"
    }
    
    public static func argument(named name: String, argType: CommandArgumentType = .required) throws -> CommandArgument {
        let argType: CommandArgumentType = argType.optional ? .optionalConsume : .requiredConsume
        return CommandArgument(componentType: self.typedName, componentName: name, type: argType)
    }
    
    public static var canConsume: Bool {
        return true
    }
    
    public static func resolveArgument(_ argument: String, on event: CommandEvent) throws -> ResolvedArgument {
        let args = argument.split(separator: " ").map(String.init)
        var arr: ResolvedArgument = []
        try args.forEach {
            try arr.append(Element.resolveArgument($0, on: event))
        }
        return arr
    }
}

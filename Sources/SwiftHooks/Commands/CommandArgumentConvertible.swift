import struct Foundation.UUID

/// Marks a type as `CommandArgumentConvertible`.
///
/// These types can be created from one or more arguments passed into a command.
public protocol CommandArgumentConvertible {
    /// The type arguments will be resolved to.
    ///
    /// Defaults to `Self`
    associatedtype ResolvedArgument = Self
    
    /// Name used in descriptions.
    ///
    ///     Int.typedName // "Int"
    ///
    static var typedName: String { get }
    
    /// Attempts to resolve an argument from the provided string.
    ///
    /// - parameters:
    ///     - argument: String taken from the message body.
    ///     - event: The `CommandEvent` this argument should be resolved for.
    ///
    /// - throws:
    ///     `CommandError.UnableToConvertArgument` when `ResolvedArgument` can not be created from `argument`
    ///     `CommandError.ArgumentNotFound` when no argument is found
    ///
    /// - returns: The resolved argument
    static func resolveArgument(_ argument: String, on event: CommandEvent) throws -> ResolvedArgument
    
    /// Attempts to resolve an argument from the provided string.
    ///
    /// A default implementation is provided. The default implementation
    /// will throw `CommandArgument.ArgumentNotFound` when `nil` is passed in.
    ///
    /// - parameters:
    ///     - argument: String taken from the message body.
    ///     - event: The `CommandEvent` this argument should be resolved for.
    ///
    /// - throws:
    ///     `CommandError.UnableToConvertArgument` when `ResolvedArgument` can not be created from `argument`
    ///     `CommandError.ArgumentNotFound` when no argument is found
    ///
    /// - returns: The resolved argument
    static func resolveArgument(_ argument: String?, arg: CommandArgument, on event: CommandEvent) throws -> ResolvedArgument
}

/// Marks a type as both `CommandArgumentConvertible` and `Consuming`.
///
/// `ConsumingCommandArgumentConvertible` types will not take a single arguments, but rather `[x...]`, consuming the entire list of arguments.
/// Examples of arguments that support consuming are `Array` and `String.Consuming`
public protocol ConsumingCommandArgumentConvertible: CommandArgumentConvertible, AnyConsuming { }

/// A representation of an unresolved argument
public protocol CommandArgument: CustomStringConvertible {
    /// Indicating wether or not the argument is optional and can be `nil`.
    var isOptional: Bool { get }
    /// Indicating wether or not the argument is consuming, or will take a single argument.
    var isConsuming: Bool { get }
    /// The type of the argument.
    var componentType: String { get }
    /// The name of the argument.
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

/// Any type capable of consuming.
///
/// See also `ConsumingCommandArgumentConvertible`
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
    /// Helper to create consuming `String` arguments.
    ///
    ///     Command("test")
    ///         .arg(String.Consuming.self, "consumingString")
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

    /// Attempts to resolve an argument from the provided string.
    ///
    /// - parameters:
    ///     - argument: String taken from the message body.
    ///     - event: The `CommandEvent` this argument should be resolved for.
    ///
    /// - throws:
    ///     `CommandError.UnableToConvertArgument` when `ResolvedArgument` can not be created from `argument`
    ///     `CommandError.ArgumentNotFound` when no argument is found
    ///
    /// - returns: The resolved argument
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

    /// Attempts to resolve an argument from the provided string.
    ///
    /// - parameters:
    ///     - argument: String taken from the message body.
    ///     - event: The `CommandEvent` this argument should be resolved for.
    ///
    /// - throws:
    ///     `CommandError.UnableToConvertArgument` when `ResolvedArgument` can not be created from `argument`
    ///     `CommandError.ArgumentNotFound` when no argument is found
    ///
    /// - returns: The resolved argument
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

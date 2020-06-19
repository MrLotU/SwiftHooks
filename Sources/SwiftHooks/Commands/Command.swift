import class NIO.EventLoopFuture

public protocol AnyFuture {
    func toVoidFuture() -> EventLoopFuture<Void>
}

extension EventLoopFuture: AnyFuture {
    @inlinable
    public func toVoidFuture() -> EventLoopFuture<Void> {
        self.map { _ in }
    }
}

/// Base command
public struct Command: ExecutableCommand {
    public let name: String
    public let group: String?
    public let alias: [String]
    public let hookWhitelist: [HookID]
    public let permissionChecks: [CommandPermissionChecker]
    public let closure: (CommandEvent) -> AnyFuture
    
    public func invoke(on event: CommandEvent) -> EventLoopFuture<Void> {
        return closure(event).toVoidFuture()
    }
    
    public func copyWith(name: String, group: String?, alias: [String], hookWhitelist: [HookID], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute) -> Self {
        return .init(name: name, group: group, alias: alias, hookWhitelist: hookWhitelist, permissionChecks: permissionChecks, closure: closure)
    }
    
    internal init(name: String, group: String?, alias: [String], hookWhitelist: [HookID], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute) {
        self.name = name
        self.group = group
        self.alias = alias
        self.hookWhitelist = hookWhitelist
        self.permissionChecks = permissionChecks
        self.closure = closure
    }
    
    /// Create a new command.
    ///
    /// - parameters:
    ///     - name: Name and trigger of the command.
    public init(_ name: String) {
        self.name = name
        self.group = nil
        self.alias = []
        self.hookWhitelist = []
        self.permissionChecks = []
        self.closure = { e in e.eventLoop.makeSucceededFuture(()) }
    }

    public func validate() throws { }
    
    /// Add an argument to this command
    ///
    ///     Command("echo")
    ///         .arg(String.Consuming.self, named: "content")
    ///
    /// - parameters:
    ///     - t: Type of the argument.
    ///     - name: Name of the argument.
    public func arg<A>(_ t: A.Type, named name: String) -> OneArgCommand<A> {
        let x = GenericCommandArgument<A>(componentType: A.typedName, componentName: name)
        return OneArgCommand<A>(
            name: self.name,
            group: group,
            alias: alias,
            hookWhitelist: hookWhitelist,
            permissionChecks: permissionChecks,
            closure: { e, _ in e.eventLoop.makeSucceededFuture(()) },
            arg: x
        )
    }
}

fileprivate extension ExecutableCommand {
    func getArg<T>(_ t: T.Type = T.self, _ index: inout Int, for arg: CommandArgument, on event: CommandEvent) throws -> T.ResolvedArgument where T: CommandArgumentConvertible {
        func parse(_ s: String?) throws -> T.ResolvedArgument {
            let t = try T.resolveArgument(s, arg: arg, on: event)
            if (t as? AnyOptionalType)?.isNil ?? false {
                return t
            }
            index += 1
            return t
        }
        if arg.isConsuming {
            let s = event.args[index...].joined(separator: " ")
            return try parse(s)
        }
        return try parse(event.args[safe:index])
    }
}

/// Base command with one argument
public struct OneArgCommand<A>: ExecutableCommand where A: CommandArgumentConvertible {
    public let name: String
    public let group: String?
    public let alias: [String]
    public let hookWhitelist: [HookID]
    public let permissionChecks: [CommandPermissionChecker]
    public let closure: (CommandEvent, A.ResolvedArgument) -> AnyFuture
    public var readableArguments: String? {
        arg.description
    }
    
    let arg: CommandArgument
    
    public func copyWith(name: String, group: String?, alias: [String], hookWhitelist: [HookID], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute) -> Self {
        return .init(name: name, group: group, alias: alias, hookWhitelist: hookWhitelist, permissionChecks: permissionChecks, closure: closure, arg: arg)
    }
    
    internal init(name: String, group: String?, alias: [String], hookWhitelist: [HookID], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute, arg: CommandArgument) {
        self.name = name
        self.group = group
        self.alias = alias
        self.hookWhitelist = hookWhitelist
        self.permissionChecks = permissionChecks
        self.closure = closure
        self.arg = arg
    }
    
    public func validate() throws { }
    
    public func invoke(on event: CommandEvent) -> EventLoopFuture<Void> {
        let p = event.eventLoop.makePromise(of: Void.self)
        do {
            var idx = 0
            let a = try getArg(A.self, &idx, for: arg, on: event)
            closure(event, a).toVoidFuture().cascade(to: p)
        } catch {
            p.fail(error)
        }
        return p.futureResult
    }
        
    /// Add an argument to this command
    ///
    ///     Command("echo")
    ///         .arg(String.Consuming.self, named: "content")
    ///
    /// - parameters:
    ///     - t: Type of the argument.
    ///     - name: Name of the argument.
    public func arg<B>(_ t: B.Type, named name: String) -> TwoArgCommand<A, B> {
        return TwoArgCommand<A, B>(
            name: self.name,
            group: group,
            alias: alias,
            hookWhitelist: hookWhitelist,
            permissionChecks: permissionChecks,
            closure: { e, _, _ in e.eventLoop.makeSucceededFuture(()) },
            argOne: arg,
            argTwo: GenericCommandArgument<B>(componentType: B.typedName, componentName: name)
        )
    }
}

/// Base command with two arguments
public struct TwoArgCommand<A, B>: ExecutableCommand where A: CommandArgumentConvertible, B: CommandArgumentConvertible {
    public let name: String
    public let group: String?
    public let alias: [String]
    public let hookWhitelist: [HookID]
    public let permissionChecks: [CommandPermissionChecker]
    public let closure: (CommandEvent, A.ResolvedArgument, B.ResolvedArgument) -> AnyFuture
    public var readableArguments: String? {
        [argOne, argTwo].map(\.description).joined(separator: " ")
    }
    
    public func copyWith(name: String, group: String?, alias: [String], hookWhitelist: [HookID], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute) -> Self {
        return .init(name: name, group: group, alias: alias, hookWhitelist: hookWhitelist, permissionChecks: permissionChecks, closure: closure, argOne: argOne, argTwo: argTwo)
    }
    
    internal init(name: String, group: String?, alias: [String], hookWhitelist: [HookID], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute, argOne: CommandArgument, argTwo: CommandArgument) {
        self.name = name
        self.group = group
        self.alias = alias
        self.hookWhitelist = hookWhitelist
        self.permissionChecks = permissionChecks
        self.closure = closure
        self.argOne = argOne
        self.argTwo = argTwo
    }
    
    let argOne: CommandArgument
    let argTwo: CommandArgument
    
    public func validate() throws {
        if argOne.isConsuming {
            throw CommandError.ConsumingArgumentIsNotLast(argOne.componentName)
        }
    }

    public func invoke(on event: CommandEvent) -> EventLoopFuture<Void> {
        let p = event.eventLoop.makePromise(of: Void.self)
        do {
            var idx = 0
            let a = try getArg(A.self, &idx, for: argOne, on: event)
            let b = try getArg(B.self, &idx, for: argTwo, on: event)
            self.closure(event, a, b).toVoidFuture().cascade(to: p)
        } catch {
            p.fail(error)
        }
        return p.futureResult
    }
    
    /// Add an argument to this command
    ///
    ///     Command("echo")
    ///         .arg(String.Consuming.self, named: "content")
    ///
    /// - parameters:
    ///     - t: Type of the argument.
    ///     - name: Name of the argument.
    public func arg<C>(_ t: C.Type, named name: String) -> ThreeArgCommand<A, B, C> {
        return ThreeArgCommand<A, B, C>(
            name: self.name,
            group: group,
            alias: alias,
            hookWhitelist: hookWhitelist,
            permissionChecks: permissionChecks,
            closure: { e, _, _, _ in e.eventLoop.makeSucceededFuture(()) },
            argOne: argOne,
            argTwo: argTwo,
            argThree: GenericCommandArgument<C>(componentType: C.typedName, componentName: name)
        )
    }
}

/// Base command with three arguments
public struct ThreeArgCommand<A, B, C>: ExecutableCommand where A: CommandArgumentConvertible, B: CommandArgumentConvertible, C: CommandArgumentConvertible {
    public let name: String
    public let group: String?
    public let alias: [String]
    public let hookWhitelist: [HookID]
    public let permissionChecks: [CommandPermissionChecker]
    public let closure: (CommandEvent, A.ResolvedArgument, B.ResolvedArgument, C.ResolvedArgument) -> AnyFuture
    public var readableArguments: String? {
        [argOne, argTwo, argThree].map(\.description).joined(separator: " ")
    }
    
    public func copyWith(name: String, group: String?, alias: [String], hookWhitelist: [HookID], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute) -> Self {
        return .init(name: name, group: group, alias: alias, hookWhitelist: hookWhitelist, permissionChecks: permissionChecks, closure: closure, argOne: argOne, argTwo: argTwo, argThree: argThree)
    }
    
    internal init(name: String, group: String?, alias: [String], hookWhitelist: [HookID], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute, argOne: CommandArgument, argTwo: CommandArgument, argThree: CommandArgument) {
        self.name = name
        self.group = group
        self.alias = alias
        self.hookWhitelist = hookWhitelist
        self.permissionChecks = permissionChecks
        self.closure = closure
        self.argOne = argOne
        self.argTwo = argTwo
        self.argThree = argThree
    }
    
    let argOne: CommandArgument
    let argTwo: CommandArgument
    let argThree: CommandArgument
    
    public func validate() throws {
        if argOne.isConsuming {
            throw CommandError.ConsumingArgumentIsNotLast(argOne.componentName)
        }
        if argTwo.isConsuming {
            throw CommandError.ConsumingArgumentIsNotLast(argTwo.componentName)
        }
    }

    public func invoke(on event: CommandEvent) -> EventLoopFuture<Void> {
        let p = event.eventLoop.makePromise(of: Void.self)
        do {
            var idx = 0
            let a = try getArg(A.self, &idx, for: argOne, on: event)
            let b = try getArg(B.self, &idx, for: argTwo, on: event)
            let c = try getArg(C.self, &idx, for: argThree, on: event)
            self.closure(event, a, b, c).toVoidFuture().cascade(to: p)
        } catch {
            p.fail(error)
        }
        return p.futureResult
    }
    
    /// Add an argument to this command
    ///
    ///     Command("echo")
    ///         .arg(String.Consuming.self, named: "content")
    ///
    /// - parameters:
    ///     - t: Type of the argument.
    ///     - name: Name of the argument.
    public func arg<T>(_ t: T.Type, named name: String) -> ArrayArgCommand where T: CommandArgumentConvertible {
        return ArrayArgCommand(
            name: self.name,
            group: group,
            alias: alias,
            hookWhitelist: hookWhitelist,
            permissionChecks: permissionChecks,
            closure: { e, _ in e.eventLoop.makeSucceededFuture(()) },
            arguments: [argOne, argTwo, argThree, GenericCommandArgument<T>(componentType: T.typedName, componentName: name)]
        )
    }
}

/// Base command with four or more arguments
public struct ArrayArgCommand: ExecutableCommand {
    public let name: String
    public let group: String?
    public let alias: [String]
    public let hookWhitelist: [HookID]
    public let permissionChecks: [CommandPermissionChecker]
    public let closure: (CommandEvent, Arguments) throws -> AnyFuture
    /// Arguments for this command.
    public let arguments: [CommandArgument]
    
    public var readableArguments: String? {
        return self.arguments.map(\.description).joined(separator: " ")
    }
    
    public func copyWith(name: String, group: String?, alias: [String], hookWhitelist: [HookID], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute) -> ArrayArgCommand {
        return .init(name: name, group: group, alias: alias, hookWhitelist: hookWhitelist, permissionChecks: permissionChecks, closure: closure, arguments: arguments)
    }
    
    internal init(name: String, group: String?, alias: [String], hookWhitelist: [HookID], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute, arguments: [CommandArgument]) {
        self.name = name
        self.group = group
        self.alias = alias
        self.hookWhitelist = hookWhitelist
        self.permissionChecks = permissionChecks
        self.closure = closure
        self.arguments = arguments
    }
    
    public func validate() throws {
        try self.arguments.enumerated().forEach { (index, item) in
            if item.isConsuming && !(index == arguments.endIndex - 1) {
                throw CommandError.ConsumingArgumentIsNotLast(item.componentName)
            }
        }
    }
    
    public func invoke(on event: CommandEvent) -> EventLoopFuture<Void> {
        let p = event.eventLoop.makePromise(of: Void.self)
        do {
            try closure(event, Arguments(arguments)).toVoidFuture().cascade(to: p)
        } catch {
            p.fail(error)
        }
        return p.futureResult
    }
    
    /// Add an argument to this command
    ///
    ///     Command("echo")
    ///         .arg(String.Consuming.self, named: "content")
    ///
    /// - parameters:
    ///     - t: Type of the argument.
    ///     - name: Name of the argument.
    public func arg<T>(_ t: T.Type, named name: String) -> ArrayArgCommand where T: CommandArgumentConvertible {
        return ArrayArgCommand(
            name: self.name,
            group: group,
            alias: alias,
            hookWhitelist: hookWhitelist,
            permissionChecks: permissionChecks,
            closure: { e, _ in e.eventLoop.makeSucceededFuture(()) },
            arguments: arguments + GenericCommandArgument<T>(componentType: T.typedName, componentName: name)
        )
    }
}


/// Arguments container used in `ArrayArgCommand`.
public class Arguments {
    let arguments: [CommandArgument]
    private(set) var nilArgs: [String]
    
    init(_ arguments: [CommandArgument]) {
        self.arguments = arguments
        self.nilArgs = []
    }
    
    /// Resolve an argument from the command arguments
    ///
    ///     let reason = try args.get(String.self, named: "reason", on: event)
    ///
    /// - parameters:
    ///     - arg: Type to resolve.
    ///     - name: Name of the argument to resolve.
    ///     - event: `CommandEvent` to resolve on.
    ///
    /// - throws:
    ///     `CommandError.UnableToConvertArgument` when resolving fails.
    ///     `CommandError.ArgumentNotFound` when no argument is found.
    ///
    /// - returns: The resolved argument.
    public func get<A>(_ arg: A.Type, named name: String, on event: CommandEvent) throws -> A.ResolvedArgument where A: CommandArgumentConvertible {
        guard let foundArg = self.arguments.first(where: {
            $0.componentType == arg.typedName &&
            $0.componentName == name
        }), let tempIndex = arguments.firstIndex(where: { $0 == foundArg }) else {
            throw CommandError.ArgumentNotFound(name)
        }
        let earlierArgs = arguments[0..<tempIndex].reduce(0) { return $0 + (self.nilArgs.contains($1.description) ? 1 : 0) }
        let index = tempIndex - earlierArgs
        func parse(_ s: String?) throws -> A.ResolvedArgument {
            let a = try A.resolveArgument(s, arg: foundArg, on: event)
            if (a as? AnyOptionalType)?.isNil ?? false {
                self.nilArgs.append(foundArg.description)
                return a
            }
            return a
        }
        if foundArg.isConsuming {
            let string = event.args[index...].joined(separator: " ")
            return try parse(string)
        }
        return try parse(event.args[safe:index])
    }
}

fileprivate extension Array {
    subscript(safe index: Int) -> Element? {
        return (index >= 0 && index < count) ? self[index] : nil
    }
}

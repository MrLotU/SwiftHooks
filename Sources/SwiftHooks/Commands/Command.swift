public struct Command: ExecutableCommand {
    public let name: String
    public let group: String?
    public var alias: [String]
    public var permissionChecks: [CommandPermissionChecker]
    public let closure: (SwiftHooks, CommandEvent) throws -> Void
    
    public func invoke(on event: CommandEvent, using hooks: SwiftHooks) throws {
        try closure(hooks, event)
    }
    
    public func copyWith(name: String, group: String?, alias: [String], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute) -> Self {
        return .init(name: name, group: group, alias: alias, permissionChecks: permissionChecks, closure: closure)
    }
    
    internal init(name: String, group: String?, alias: [String], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute) {
        self.name = name
        self.group = group
        self.alias = alias
        self.permissionChecks = permissionChecks
        self.closure = closure
    }
    
    public init(_ name: String) {
        self.name = name
        self.group = nil
        self.alias = []
        self.permissionChecks = []
        self.closure = { _, _ in }
    }

    public func arg<A>(_ t: A.Type, named n: String, _ type: CommandArgumentType = .required) -> OneArgCommand<A> {
        return OneArgCommand<A>(
            name: name,
            group: group,
            alias: alias,
            permissionChecks: permissionChecks,
            closure: { _, _, _ in },
            arg: CommandArgument(componentType: A.typedName, componentName: n, type: type)
        )
    }
}

fileprivate extension ExecutableCommand {
    func getArg<T>(_ t: T.Type = T.self, _ index: Int, for arg: CommandArgument, on event: CommandEvent) throws -> T.ResolvedArgument where T: CommandArgumentConvertible {
        func parse(_ s: String) throws -> T.ResolvedArgument {
            if !arg.type.optional && s.isEmpty {
                throw CommandError.ArgumentNotFound(name)
            }
            return try T.resolveArgument(s, on: event)
        }
        if arg.type.consumes {
            guard T.canConsume else { throw CommandError.ArgumentCanNotConsume }
            let s = event.args[index...].joined(separator: " ")
            return try parse(s)
        }
        guard let s = event.args[safe:index] else {
            throw CommandError.ArgumentNotFound(arg.componentName)
        }
        return try parse(s)
    }
}

public struct OneArgCommand<A>: ExecutableCommand where A: CommandArgumentConvertible {
    public let name: String
    public let group: String?
    public let alias: [String]
    public let permissionChecks: [CommandPermissionChecker]
    public let closure: (SwiftHooks, CommandEvent, A.ResolvedArgument) throws -> Void
    public var readableArguments: String? {
        arg.description
    }
    
    let arg: CommandArgument
    
    public func copyWith(name: String, group: String?, alias: [String], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute) -> Self {
        return .init(name: name, group: group, alias: alias, permissionChecks: permissionChecks, closure: closure, arg: arg)
    }
    
    internal init(name: String, group: String?, alias: [String], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute, arg: CommandArgument) {
        self.name = name
        self.group = group
        self.alias = alias
        self.permissionChecks = permissionChecks
        self.closure = closure
        self.arg = arg
    }
    
    public func invoke(on event: CommandEvent, using hooks: SwiftHooks) throws {
        let a = try getArg(A.self, 0, for: arg, on: event)
        try closure(hooks, event, a)
    }
        
    public func arg<B>(_ t: B.Type, named: String, _ type: CommandArgumentType = .required) -> TwoArgCommand<A, B> {
        return TwoArgCommand<A, B>(
            name: name,
            group: group,
            alias: alias,
            permissionChecks: permissionChecks,
            closure: { _, _, _, _ in },
            argOne: arg,
            argTwo: .init(componentType: B.typedName, componentName: named, type: type)
        )
    }
}

public struct TwoArgCommand<A, B>: ExecutableCommand where A: CommandArgumentConvertible, B: CommandArgumentConvertible {
    public let name: String
    public let group: String?
    public let alias: [String]
    public let permissionChecks: [CommandPermissionChecker]
    public let closure: (SwiftHooks, CommandEvent, A.ResolvedArgument, B.ResolvedArgument) throws -> Void
    public var readableArguments: String? {
        [argOne, argTwo].map(\.description).joined(separator: " ")
    }
    
    public func copyWith(name: String, group: String?, alias: [String], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute) -> Self {
        return .init(name: name, group: group, alias: alias, permissionChecks: permissionChecks, closure: closure, argOne: argOne, argTwo: argTwo)
    }
    
    internal init(name: String, group: String?, alias: [String], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute, argOne: CommandArgument, argTwo: CommandArgument) {
        self.name = name
        self.group = group
        self.alias = alias
        self.permissionChecks = permissionChecks
        self.closure = closure
        self.argOne = argOne
        self.argTwo = argTwo
    }
    
    let argOne: CommandArgument
    let argTwo: CommandArgument

    public func invoke(on event: CommandEvent, using hooks: SwiftHooks) throws {
        let a = try getArg(A.self, 0, for: argOne, on: event)
        let b = try getArg(B.self, 1, for: argTwo, on: event)
        try self.closure(hooks, event, a, b)
    }
    
    public func arg<C>(_ t: C.Type, named: String, _ type: CommandArgumentType = .required) -> ThreeArgCommand<A, B, C> {
        return ThreeArgCommand<A, B, C>(
            name: name,
            group: group,
            alias: alias,
            permissionChecks: permissionChecks,
            closure: { _, _, _, _, _ in },
            argOne: argOne,
            argTwo: argTwo,
            argThree: CommandArgument(componentType: C.typedName, componentName: named, type: type)
        )
    }
}

public struct ThreeArgCommand<A, B, C>: ExecutableCommand where A: CommandArgumentConvertible, B: CommandArgumentConvertible, C: CommandArgumentConvertible {
    public let name: String
    public let group: String?
    public let alias: [String]
    public let permissionChecks: [CommandPermissionChecker]
    public let closure: (SwiftHooks, CommandEvent, A.ResolvedArgument, B.ResolvedArgument, C.ResolvedArgument) throws -> Void
    public var readableArguments: String? {
        [argOne, argTwo, argThree].map(\.description).joined(separator: " ")
    }
    
    public func copyWith(name: String, group: String?, alias: [String], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute) -> Self {
        return .init(name: name, group: group, alias: alias, permissionChecks: permissionChecks, closure: closure, argOne: argOne, argTwo: argTwo, argThree: argThree)
    }
    
    internal init(name: String, group: String?, alias: [String], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute, argOne: CommandArgument, argTwo: CommandArgument, argThree: CommandArgument) {
        self.name = name
        self.group = group
        self.alias = alias
        self.permissionChecks = permissionChecks
        self.closure = closure
        self.argOne = argOne
        self.argTwo = argTwo
        self.argThree = argThree
    }
    
    let argOne: CommandArgument
    let argTwo: CommandArgument
    let argThree: CommandArgument

    public func invoke(on event: CommandEvent, using hooks: SwiftHooks) throws {
        let a = try getArg(A.self, 0, for: argOne, on: event)
        let b = try getArg(B.self, 1, for: argTwo, on: event)
        let c = try getArg(C.self, 2, for: argThree, on: event)
        try self.closure(hooks, event, a, b, c)
    }
    
    public func arg<T>(_ t: T.Type, named: String, _ type: CommandArgumentType = .required) -> ArrayArgCommand where T: CommandArgumentConvertible {
        return ArrayArgCommand(
            name: name,
            group: group,
            alias: alias,
            permissionChecks: permissionChecks,
            closure: { _, _, _ in },
            arguments: [argOne, argTwo, argThree, CommandArgument(componentType: T.typedName, componentName: named, type: type)]
        )
    }
}

public struct ArrayArgCommand: ExecutableCommand {
    public let name: String
    public let group: String?
    public let alias: [String]
    public let permissionChecks: [CommandPermissionChecker]
    public let closure: (SwiftHooks, CommandEvent, Arguments) throws -> Void
    public let arguments: [CommandArgument]
    
    public func copyWith(name: String, group: String?, alias: [String], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute) -> ArrayArgCommand {
        return .init(name: name, group: group, alias: alias, permissionChecks: permissionChecks, closure: closure, arguments: arguments)
    }
    
    internal init(name: String, group: String?, alias: [String], permissionChecks: [CommandPermissionChecker], closure: @escaping Execute, arguments: [CommandArgument]) {
        self.name = name
        self.group = group
        self.alias = alias
        self.permissionChecks = permissionChecks
        self.closure = closure
        self.arguments = arguments
    }
    
    public func invoke(on event: CommandEvent, using hooks: SwiftHooks) throws {
        try closure(hooks, event, Arguments(arguments: arguments))
    }
    
    public var readableArguments: String? {
        return self.arguments.map(\.description).joined(separator: " ")
    }
    
    public func arg<T>(_ t: T.Type, named: String, _ type: CommandArgumentType = .required) -> ArrayArgCommand where T: CommandArgumentConvertible {
        return ArrayArgCommand(
            name: name,
            group: group,
            alias: alias,
            permissionChecks: permissionChecks,
            closure: { _, _, _ in },
            arguments: arguments + CommandArgument(componentType: T.typedName, componentName: named, type: type)
        )
    }
}

public struct Arguments {
    let arguments: [CommandArgument]
    
    public func getArg<A>(named name: String, on event: CommandEvent) throws -> A where A: CommandArgumentConvertible, A.ResolvedArgument == A {
        return try self.get(A.self, named: name, on: event)
    }
    
    public func get<A>(_ arg: A.Type, named name: String, on event: CommandEvent) throws -> A.ResolvedArgument where A: CommandArgumentConvertible {
        guard let foundArg = self.arguments.first(where: {
            $0.componentType == arg.typedName &&
            $0.componentName == name
        }), let index = arguments.firstIndex(of: foundArg) else {
            throw CommandError.ArgumentNotFound(name)
        }
        func parse(_ s: String) throws -> A.ResolvedArgument {
            if !foundArg.type.optional && s.isEmpty {
                throw CommandError.ArgumentNotFound(name)
            }
            return try A.resolveArgument(s, on: event)
        }
        if foundArg.type.consumes {
            guard A.canConsume else { throw CommandError.ArgumentCanNotConsume }
            let string = event.args[index...].joined(separator: " ")
            return try parse(string)
        }
        guard let string = event.args[safe:index] else {
            throw CommandError.ArgumentNotFound(name)
        }
        return try parse(string)
    }
}

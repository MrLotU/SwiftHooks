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
        let parts = event.message.content.split(separator: " ").map(String.init)
        let a = try A.resolveArgument(parts[1])
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
            argTwo: .init(componentType: B.typedName, componentName: name, type: type)
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
        let parts = event.message.content.split(separator: " ").map(String.init)
        let a = try A.resolveArgument(parts[1])
        let b = try B.resolveArgument(parts[2])
        try self.closure(hooks, event, a, b)
    }
}


internal extension Array {
    static func + (_ lhs: Self, _ rhs: Element) -> Self {
        var new = lhs
        new.append(rhs)
        return new
    }
}

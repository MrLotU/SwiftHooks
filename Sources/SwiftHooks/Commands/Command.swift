public typealias CommandClosure = (SwiftHooks, CommandEvent, Command) throws -> Void

@propertyWrapper
public final class Command {
    let name: String
    let group: String?
    let arguments: [CommandArgument]
    let aliases: [String]
    let permChecks: [CommandPermissionChecker]
    let userInfo: [String: Any]

    public let wrappedValue: CommandClosure
    
    public init() {
        preconditionFailure("Commands must always have a name.")
    }
    
    public func invoke(on event: CommandEvent, using hooks: SwiftHooks) throws {
        for check in permChecks {
            if !check.check(event.user, canUse: self, on: event) {
                throw CommandError.InvalidPermissions
            }
        }
        try wrappedValue(hooks, event, self)
    }
    
    #if swift(>=5.2)
    public init(wrappedValue c: @escaping CommandClosure, _ name: String, _ args: CommandArgument..., group: String? = nil, aliases: [String] = [], permChecks: [CommandPermissionChecker] = [], userInfo: [String: Any] = [:]) {
        self.wrappedValue = c
        self.name = name
        self.arguments = args
        self.group = group
        self.aliases = aliases
        self.permChecks = permChecks
        self.userInfo = userInfo
    }


    public init(_ name: String, args: [CommandArgument] = [], group: String? = nil, aliases: [String] = [], permChecks: [CommandPermissionChecker] = [], userInfo: [String: Any] = [:]) {
        self.name = name
        self.arguments = args
        self.group = group
        self.aliases = aliases
        self.permChecks = permChecks
        self.userInfo = userInfo
        self.wrappedValue = { _, _, _ in }
    }
    #else
    public init(wrappedValue c: @escaping CommandClosure, _ name: String, _ args: [CommandArgument], group: String?, aliases: [String], permChecks: [CommandPermissionChecker], userInfo: [String: Any]) {
        self.wrappedValue = c
        self.name = name
        self.arguments = args
        self.group = group
        self.aliases = aliases
        self.permChecks = permChecks
        self.userInfo = userInfo
    }
    
    public convenience init(wrappedValue c: @escaping CommandClosure, _ name: String) {
        self.init(wrappedValue: c, name, [], group: nil, aliases: [], permChecks: [], userInfo: [:])
    }

    public convenience init(wrappedValue c: @escaping CommandClosure, _ name: String, _ args: [CommandArgument]) {
        self.init(wrappedValue: c, name, args, group: nil, aliases: [], permChecks: [], userInfo: [:])
    }

    public convenience init(wrappedValue c: @escaping CommandClosure, _ name: String, _ args: [CommandArgument], group: String?) {
        self.init(wrappedValue: c, name, args, group: group, aliases: [], permChecks: [], userInfo: [:])
    }

    public convenience init(wrappedValue c: @escaping CommandClosure, _ name: String, _ args: [CommandArgument], group: String?, aliases: [String]) {
        self.init(wrappedValue: c, name, args, group: nil, aliases: aliases, permChecks: [], userInfo: [:])
    }

    public convenience init(wrappedValue c: @escaping CommandClosure, _ name: String, _ args: [CommandArgument], group: String?, aliases: [String], permChecks: [CommandPermissionChecker]) {
        self.init(wrappedValue: c, name, args, group: nil, aliases: aliases, permChecks: permChecks, userInfo: [:])
    }
    #endif
}

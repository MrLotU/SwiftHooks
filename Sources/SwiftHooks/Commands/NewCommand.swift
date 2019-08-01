@propertyWrapper
public final class CCommand {
    let name: String
    let group: String?
    let arguments: [CommandArgument]
    let aliases: [String]
    let permChecks: [CommandPermissionChecker]
    let userInfo: [String: Any]
    
    let executable: Bool
    
    public var wrappedValue: CommandClosure!
    
    public init() {
        preconditionFailure("Commands must always have a name.")
    }
    
    var command: Command {
        return Command(trigger: name, arguments: arguments, aliases: aliases, group: group, permissionChecks: permChecks, userInfo: userInfo, execute: self.wrappedValue)
    }
    
    public init(wrappedValue initialValue: CommandClosure?) {
        self.wrappedValue = initialValue
        fatalError()
    }
    
    public init(_ name: String, args: CommandArgument..., group: String? = nil, aliases: [String] = [], permChecks: [CommandPermissionChecker] = [], userInfo: [String: Any] = [:]) {
        self.name = name
        self.arguments = args
        self.group = group
        self.aliases = aliases
        self.permChecks = permChecks
        self.userInfo = userInfo
        self.executable = true
    }
}

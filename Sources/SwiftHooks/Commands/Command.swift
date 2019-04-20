public struct Command {
    
    public let trigger: String
//    public let arguments: [CommandArgument]
    public let aliases: String
    public let group: String?
    public let permissionChecks: [CommandPermissionChecker]
    public let userInfo: [String: Any]
//    public let execute: CommandClosure

    
}

public struct CommandEvent { }

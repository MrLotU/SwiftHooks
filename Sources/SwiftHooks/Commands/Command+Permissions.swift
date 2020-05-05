/// Check if the given user has the permission to execute the command.
///
///     let checker = MyChecker()
///     guard checker.check(user, canUse: command, on: event) else { throw CommandError.InvalidPermissions }
///
public protocol CommandPermissionChecker {
    
    /// Check if the given user has the permission to execute the command.
    ///
    ///     let checker = MyChecker()
    ///     guard checker.check(user, canUse: command, on: event) else { throw CommandError.InvalidPermissions }
    ///
    /// - Parameters:
    ///     - user: User executing the command
    ///     - command: Command being executed
    ///     - event: Event holding the command & related info
    ///
    /// - Returns: Wether or not the user is allowed to execute the command
    func check(_ user: Userable, canUse command: _ExecutableCommand, on event: CommandEvent) -> Bool
}

/// Checks if a user is allowed to execute based on their ID
///
///     let checker = IDChecker(ids: ["123"])
///     let user = User(id: "456")
///     checker.check(user, canUse: command, on: event) // false
///     let userTwo = User(id: "123")
///     checker.check(userTwo, canUse: command, on: event) // true
///
public struct IDChecker: CommandPermissionChecker {
    
    /// List of whitelisted IDs
    let ids: [String]
    
    public func check(_ user: Userable, canUse command: _ExecutableCommand, on event: CommandEvent) -> Bool {
        guard let id = user.identifier else { return false }
        return ids.contains(id)
    }
}

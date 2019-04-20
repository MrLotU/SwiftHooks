public protocol CommandPermissionChecker {
    func check<U: Userable>(_ user: U, canUse command: Command, on event: CommandEvent) -> Bool
}

/// Checks if a user is allowed to execute based on their ID
///
///     let checker = IDChecker(ids: ["123"])
///     let user = User(id: "456")
///     checker.check(user, canUse: command, on: event) // false
///     let userTwo = User(id: "123")
///     checker.check(userTwo, canUse: command, on: event) // true
public struct IDChecker: CommandPermissionChecker {
    
    let ids: [String]
    
    public func check<U>(_ user: U, canUse command: Command, on event: CommandEvent) -> Bool where U : Userable {
        guard let id = user.id as? String else { return false }
        return ids.contains(id)
    }
}

extension SwiftHooks {
    public func command(
        _ trigger: String,
        _ args: [CommandArgument],
        aliases: [String] = [],
        group: String? = nil,
        permissionChecks: [CommandPermissionChecker] = [],
        userInfo: [String: Any] = [:],
        execute: @escaping CommandClosure) throws
    {
        // TODO: Make case sensitivity an option
        let trigger = trigger.lowercased()
        let aliases = aliases.map { $0.lowercased() }
        if !self.commands.filter({ comm in
            if group != comm.group {
                return false
            }
            return comm.trigger == trigger ||
                comm.aliases.contains(trigger) ||
                aliases.contains(comm.trigger) ||
                !aliases.filter {
                    return comm.aliases.contains($0)
                }.isEmpty
        }).isEmpty {
            throw CommandError.CommandRedeclaration
        }
        let command = Command(trigger: trigger, arguments: args, aliases: aliases, group: group, permissionChecks: permissionChecks, userInfo: userInfo, execute: execute)
        self.commands.append(command)
    }
    
    public func command(
        _ trigger: String,
        _ args: CommandArgument...,
        aliases: [String] = [],
        group: String? = nil,
        permissionChecks: [CommandPermissionChecker] = [],
        userInfo: [String: Any] = [:],
        execute: @escaping CommandClosure) throws
    {
        try self.command(trigger, args, aliases: aliases, group: group, permissionChecks: permissionChecks, userInfo: userInfo, execute: execute)
    }
    
    func handleMessage(_ message: Messageable) {
        let foundCommands = self.findCommands(for: message)
        
        foundCommands.forEach { (command) in
            let event = CommandEvent(hooks: self, cmd: command, msg: message)
            
            do {
                try command.invoke(on: event, using: self)
            } catch CommandError.ArgumentNotFound(let arg) {
                event.message.reply("Missing argument \(arg)!")
            } catch CommandError.ArgumentCanNotConsume {
                event.message.reply("Too many arguments!")
            } catch CommandError.InvalidPermissions {
                event.message.reply("Invalid permissions!")
            } catch CommandError.UnableToConvertArgument(let arg, let type) {
                event.message.reply("Error converting \(arg) to \(type)")
            } catch {
                event.message.reply("Something went wrong!")
                self.logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    func findCommands(for message: Messageable) -> [Command] {
        return self.commands.compactMap { return message.content.starts(with: "!" + $0.fullTrigger) ? $0 : nil }
    }
}

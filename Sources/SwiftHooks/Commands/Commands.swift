/// Commands used in `Plugin`s
public protocol Commands {
    /// Get all executable commands.
    func executables() -> [_ExecutableCommand]
    
    /// Add a group prefix to these commands.
    func group(_ group: String) -> Self
}

/// NOOP provider for `Commands`.
public struct NoCommands: Commands {
    public func executables() -> [_ExecutableCommand] {
        return []
    }
    
    public func group(_ group: String) -> NoCommands {
        return self
    }
}

/// Group multiple `Commands` together, optionally providing a group prefix.
///
///     Group("admin") {
///         // Admin prefixed commands
///     }
///
public struct Group: Commands {
    let commands: Commands
    
    /// Group prefix
    public let name: String?
    
    public func executables() -> [_ExecutableCommand] {
        return commands.executables()
    }
    
    /// NOTE: Only one group prefix is supported. So calling `.group(_:)` on a Group will not do anything
    public func group(_ group: String) -> Group {
        return self
    }
    
    private init(_ name: String?, commands: Commands) {
        self.name = name
        if let n = name {
            self.commands = commands.group(n)
        } else {
            self.commands = commands
        }
    }

    /// Create a new `Group`
    ///
    /// - parameters:
    ///     - name: Optionally provide a group prefix. All commands in this group will be prefixed with this.
    ///     - commands: Commands in this group.
    public init(_ name: String? = nil, @CommandBuilder commands: () -> Commands) {
        self.name = name
        if let n = name {
            self.commands = commands().group(n)
        } else {
            self.commands = commands()
        }
    }
}

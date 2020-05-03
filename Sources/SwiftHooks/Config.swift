import Foundation

/// SwiftHooks configuration. Use `.default` for default config.
public struct SwiftHooksConfig {
    public struct Commands {
        public let prefix: String
        public let enabled: Bool
        
        /// - parameters:
        ///     - prefix: Command prefix to use. Default is `!`
        ///     - enabled: Wether or not to enable commands. Default is `true`
        public init(prefix: String, enabled: Bool) {
            self.prefix = prefix
            self.enabled = enabled
        }
    }
    
    public let commands: Commands
    
    public static let `default`: SwiftHooksConfig = .init(commands: .init(prefix: "!", enabled: true))
    
    /// - parameters:
    ///     - commands: Commands configuration.
    public init(commands: Commands) {
        self.commands = commands
    }
}

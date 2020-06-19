import Foundation

/// SwiftHooks configuration. Use `.default` for default config.
public struct SwiftHooksConfig {
    public struct Commands {
        public enum Prefix {
            /// Use a static String as prefix. For example `!` or `/`
            case string(String)
            /// Use a mention as prefix.
            case mention
        }
        
        /// Command prefix used.
        public let prefix: Prefix
        /// Wether or not to enable commands.
        public let enabled: Bool
        
        /// - parameters:
        ///     - prefix: Command prefix to use. Default is mentioning your bot.
        ///     - enabled: Wether or not to enable commands. Default is `true`
        public init(prefix: Prefix, enabled: Bool) {
            self.prefix = prefix
            self.enabled = enabled
        }
    }
    
    /// Commands config
    public let commands: Commands
    
    /// Default config
    public static let `default`: SwiftHooksConfig = .init(commands: .init(prefix: .mention, enabled: true))
    
    /// - parameters:
    ///     - commands: Commands configuration.
    public init(commands: Commands) {
        self.commands = commands
    }
}

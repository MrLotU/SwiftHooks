import Foundation

public struct SwiftHooksConfig {
    public struct Commands {
        public let prefix: String
        public let enabled: Bool
        
        public init(prefix: String = "!", enabled: Bool = true) {
            self.prefix = prefix
            self.enabled = enabled
        }
    }
    
    public let commands: Commands
    
    public init(commands: Commands = Commands()) {
        self.commands = commands
    }
}

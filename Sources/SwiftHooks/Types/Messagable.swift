import NIO

public protocol Messageable: PayloadType {
    var gChannel: Channelable { get }
    var content: String { get }
    var gAuthor: Userable { get }
        
    @discardableResult
    func reply(_ content: String) -> EventLoopFuture<Messageable>
    @discardableResult
    func edit(_ content: String) -> EventLoopFuture<Messageable>
    func delete()
    func error(_ error: Error, on command: _ExecutableCommand)
}

public extension Messageable {
    func error(_ error: Error, on command: _ExecutableCommand) {
        switch error {
        case CommandError.ArgumentNotFound(let arg):
            self.reply("Missing argument: \(arg)\nUsage: \(command.help)")
        case CommandError.InvalidPermissions:
           self.reply("Invalid permissions!\nUsage: \(command.help)")
        case CommandError.UnableToConvertArgument(let arg, let type):
           self.reply("Error converting \(arg) to \(type)\nUsage: \(command.help)")
        default:
           self.reply("Something went wrong!\nUsage: \(command.help)")
       }
    }
}

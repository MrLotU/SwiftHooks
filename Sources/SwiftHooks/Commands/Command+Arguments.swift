import Foundation

extension Command {
    func getArg<A>(named name: String, on event: CommandEvent) throws -> A where A: CommandArgumentConvertible, A.ResolvedArgument == A {
        return try self.get(A.self, named: name, on: event)
    }
    
    func get<A>(_ arg: A.Type, named name: String, on event: CommandEvent) throws -> A.ResolvedArgument where A: CommandArgumentConvertible {
        guard let foundArg = self.arguments.first(where: {
            $0.componentType == arg.typedName &&
            $0.componentName == name
        }), let index = arguments.firstIndex(of: foundArg) else {
            throw CommandError.ArgumentNotFound(name)
        }
        func parse(_ s: String) throws -> A.ResolvedArgument {
            if !foundArg.type.optional && s.isEmpty {
                throw CommandError.ArgumentNotFound(name)
            }
            return try A.resolveArgument(s, on: event)
        }
        if foundArg.type.consumes {
            guard A.canConsume else { throw CommandError.ArgumentCanNotConsume }
            let string = event.args[index...].joined(separator: " ")
            return try parse(string)
        }
        guard let string = event.args[safe:index] else {
            throw CommandError.ArgumentNotFound(name)
        }
        return try parse(string)
    }
}

public enum CommandArgumentType {
    case required, requiredConsume
    case optional, optionalConsume
    
    var consumes: Bool {
        return [.requiredConsume, .optionalConsume].contains(self)
    }
    
    var optional: Bool {
        return [.optional, .optionalConsume].contains(self)
    }
}

public struct CommandArgument: CustomStringConvertible, Equatable {
    let componentType: String
    let componentName: String
    
    var type: CommandArgumentType
    
    public var description: String {
        let compType = self.type.consumes ? "\(componentType)..." : componentType
        if self.type.optional {
            return "[\(componentName):\(compType)]"
        } else {
            return "<\(componentName):\(compType)>"
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return (index >= 0 && index < count) ? self[Int(index)] : nil
    }
}

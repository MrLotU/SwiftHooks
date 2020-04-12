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
    
    let type: CommandArgumentType
    
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

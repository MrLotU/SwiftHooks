@_functionBuilder public struct CommandBuilder {
    public static func buildBlock<T>(_ command: T) -> T where T: Commands {
        return command
    }
    
    public static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> CommandTuple<(C0, C1)> where C0: Commands, C1: Commands {
        return .init(tuple: (c0, c1))
    }
    
    public static func buildBlock<C0, C1, C2>(_ c0: C0, _ c1: C1, _ c2: C2) -> CommandTuple<(C0, C1, C2)> where C0: Commands, C1: Commands, C2: Commands {
        return .init(tuple: (c0, c1, c2))
    }
    
    public static func buildBlock<C0, C1, C2, C3>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> CommandTuple<(C0, C1, C2, C3)> where C0: Commands, C1: Commands, C2: Commands, C3: Commands {
        return .init(tuple: (c0, c1, c2, c3))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> CommandTuple<(C0, C1, C2, C3, C4)> where C0: Commands, C1: Commands, C2: Commands, C3: Commands, C4: Commands {
        return .init(tuple: (c0, c1, c2, c3, c4))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) -> CommandTuple<(C0, C1, C2, C3, C4, C5)> where C0: Commands, C1: Commands, C2: Commands, C3: Commands, C4: Commands, C5: Commands {
        return .init(tuple: (c0, c1, c2, c3, c4, c5))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> CommandTuple<(C0, C1, C2, C3, C4, C5, C6)> where C0: Commands, C1: Commands, C2: Commands, C3: Commands, C4: Commands, C5: Commands, C6: Commands {
        return .init(tuple: (c0, c1, c2, c3, c4, c5, c6))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> CommandTuple<(C0, C1, C2, C3, C4, C5, C6, C7)> where C0: Commands, C1: Commands, C2: Commands, C3: Commands, C4: Commands, C5: Commands, C6: Commands, C7: Commands {
        return .init(tuple: (c0, c1, c2, c3, c4, c5, c6, c7))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> CommandTuple<(C0, C1, C2, C3, C4, C5, C6, C7, C8)> where C0: Commands, C1: Commands, C2: Commands, C3: Commands, C4: Commands, C5: Commands, C6: Commands, C7: Commands, C8: Commands {
        return .init(tuple: (c0, c1, c2, c3, c4, c5, c6, c7, c8))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) -> CommandTuple<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)> where C0: Commands, C1: Commands, C2: Commands, C3: Commands, C4: Commands, C5: Commands, C6: Commands, C7: Commands, C8: Commands, C9: Commands {
        return .init(tuple: (c0, c1, c2, c3, c4, c5, c6, c7, c8, c9))
    }
}

public struct CommandTuple<T>: Commands {
    public func executables() -> [_ExecutableCommand] {
        if let (c0, c1) = tuple as? (Commands, Commands) {
            return [c0, c1].commands()
        } else if let (c0, c1, c2) = tuple as? (Commands, Commands, Commands) {
            return [c0, c1, c2].commands()
        } else if let (c0, c1, c2, c3) = tuple as? (Commands, Commands, Commands, Commands) {
            return [c0, c1, c2, c3].commands()
        } else if let (c0, c1, c2, c3, c4) = tuple as? (Commands, Commands, Commands, Commands, Commands) {
            return [c0, c1, c2, c3, c4].commands()
        } else if let (c0, c1, c2, c3, c4, c5) = tuple as? (Commands, Commands, Commands, Commands, Commands, Commands) {
           return [c0, c1, c2, c3, c4, c5].commands()
        } else if let (c0, c1, c2, c3, c4, c5, c6) = tuple as? (Commands, Commands, Commands, Commands, Commands, Commands, Commands) {
           return [c0, c1, c2, c3, c4, c5, c6].commands()
        } else if let (c0, c1, c2, c3, c4, c5, c6, c7) = tuple as? (Commands, Commands, Commands, Commands, Commands, Commands, Commands, Commands) {
           return [c0, c1, c2, c3, c4, c5, c6, c7].commands()
        } else if let (c0, c1, c2, c3, c4, c5, c6, c7, c8) = tuple as? (Commands, Commands, Commands, Commands, Commands, Commands, Commands, Commands, Commands) {
           return [c0, c1, c2, c3, c4, c5, c6, c7, c8].commands()
        } else if let (c0, c1, c2, c3, c4, c5, c6, c7, c8, c9) = tuple as? (Commands, Commands, Commands, Commands, Commands, Commands, Commands, Commands, Commands, Commands) {
           return [c0, c1, c2, c3, c4, c5, c6, c7, c8, c9].commands()
        }
        return []
    }
    
    public func group(_ group: String) -> CommandTuple<T> {
        return self
    }
    
    let tuple: T
}

extension Array where Element == Commands {
    func commands() -> [_ExecutableCommand] {
        return self.reduce(into: []) { $0.append(contentsOf: $1.executables()) }
    }
}

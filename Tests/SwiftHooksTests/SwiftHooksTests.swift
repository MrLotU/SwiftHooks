import XCTest
@testable import SwiftHooks

var messages: [String] = []

class MyPlugin: Plugin {
    @Listener(TestEvent.messageCreate)
    var onMessage = { message in
        messages.append(message.content)
    }
    
    @GlobalListener(GlobalEvent.messageCreate)
    var onGlobalMessage = { message in
        messages.append(message.content)
    }
}

final class SwiftHooksTests: XCTestCase {
    
    func testMessage() throws {
        let hooks = SwiftHooks()
        defer { hooks.shutdown() }
        try hooks.boot()
        
        let testHook = TestHook(.init(), hooks: hooks)
        try hooks.hook(testHook)
        hooks.register(MyPlugin())
                
        testHook.dispatchEvent(TestEvent._messageCreate, with: Data())
        
        XCTAssertEqual(messages.count, 2)
        XCTAssertEqual(messages, ["!ping", "!ping"])
    }
}

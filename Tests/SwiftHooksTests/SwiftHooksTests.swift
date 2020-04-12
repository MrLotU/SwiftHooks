import XCTest
@testable import SwiftHooks

class MyPlugin: Plugin {
    var messages: [String] = []
    
    var listeners: some EventListeners {
        Listeners {
            Listener(TestEvent.messageCreate) { _, event in
                self.messages.append(event.content)
            }
            GlobalListener(GlobalEvent.messageCreate) { _, event in
                self.messages.append(event.content)
            }
        }
    }
}

final class SwiftHooksTests: XCTestCase {
    
    func testMessage() throws {
        let hooks = SwiftHooks()
        defer { hooks.shutdown() }
        
        let testHook = TestHook(.init(), hooks.eventLoopGroup)
        try hooks.hook(testHook)
        let plugin = MyPlugin()
        hooks.register(plugin)
                
        try hooks.boot()
        
        testHook.dispatchEvent(TestEvent._messageCreate, with: Data())
        
        XCTAssertEqual(plugin.messages.count, 2)
        XCTAssertEqual(plugin.messages, ["!ping", "!ping"])
    }
}

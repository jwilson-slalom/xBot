import App
import Foundation

// Uncomment for ridiculously verbose networking diagnostics
//setenv("CFNETWORK_DIAGNOSTICS", "3", 1)

try app(.detect()).asyncRun().catch { error in
    print(error)
    fatalError("This probably means the server setup threw an unhandled error during configuration")
}

RunLoop.main.run()

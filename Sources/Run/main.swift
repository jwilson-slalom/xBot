import App
import Foundation

//setenv("CFNETWORK_DIAGNOSTICS", "3", 1)

_ = try app(.detect()).asyncRun()
RunLoop.main.run()

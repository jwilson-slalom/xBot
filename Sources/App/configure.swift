import FluentSQLite
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentSQLiteProvider())

    services.register(Router.self) { container -> EngineRouter in
        let router = EngineRouter.default()
        try routes(router, container)
        return router
    }

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    services.register(SQLiteKarmaRepository.self)
    services.register(RoomController.self)
    services.register(SQLiteOnTapRepository.self)

    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .file(path: "karmaDB"))
    let ontapDatabase = try SQLiteDatabase(storage: .file(path: "onTapDB"))

    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    databases.add(database: ontapDatabase, as: .onTap)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Karma.self, database: .sqlite)
    migrations.add(model: Beer.self, database: .onTap)
    services.register(migrations)

    services.register(OnTapController.self)
    services.register(KarmaController.self)
    services.register(KarmaParser.self)
    services.register(APIKeyStorage.self)
    services.register(Slack.self)
    services.register(SlackListener.self)
}

extension DatabaseIdentifier where D: Database {

    public static var onTap: DatabaseIdentifier<SQLiteDatabase> {
        return DatabaseIdentifier<SQLiteDatabase>("com.allen.unique._ontap.database.id")
    }
}

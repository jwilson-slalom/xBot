import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
	try services.register(FluentPostgreSQLProvider())

    services.register(Router.self) { container -> EngineRouter in
        let router = EngineRouter.default()
        try routes(router, container)
        return router
    }

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

	let config: PostgreSQLDatabaseConfig
	if let databaseUrl = Environment.get("DATABASE_URL"), let herokuConfig = PostgreSQLDatabaseConfig(url: databaseUrl, transport: .unverifiedTLS) {
		config = herokuConfig
		//print("Using Heroku PostgreSQL Config")
	} else {
		//print("Using Local PostgreSQL Config")
		config = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "postgres", database: "xbot", password: nil, transport: .cleartext)
	}

	let postgres = PostgreSQLDatabase(config: config)

    // Register the configured PostgreSQL database to the database config.
    var databases = DatabasesConfig()
	databases.add(database: postgres, as: .psql)

    services.register(PostgresKarmaStatusRepository.self)
    services.register(PostgresKarmaSlackHistoryRepository.self)
    services.register(RoomController.self)

    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()

    migrations.add(model: KarmaStatus.self, database: .psql)
    migrations.add(model: KarmaSlackHistory.self, database: .psql)

    services.register(migrations)

    services.register(OnTapController.self)
    services.register(KarmaController.self)
    services.register(APIKeyStorage.self)

    services.register(Slack.self)
    services.register(SlackListener.self)
}

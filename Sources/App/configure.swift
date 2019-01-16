import FluentPostgreSQL
import Vapor
import Authentication
import Crypto

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())

    /// Register authentication provider
    try services.register(AuthenticationProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database

    /// Configure and register the PostgreSQL database to the database config.
    var config: PostgreSQLDatabaseConfig
    if let url = Environment.get("DATABASE_URL"), let psqlConfig = PostgreSQLDatabaseConfig(url: url) {
        config = psqlConfig
    } else {
       config = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "steveg", database: "memories", password: nil, transport: .unverifiedTLS)
    }

    let postgres = PostgreSQLDatabase(config: config)

    var databases = DatabasesConfig()
    databases.add(database: postgres, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Memory.self, database: .psql)
    migrations.add(model: Person.self, database: .psql)
    migrations.add(model: MemoryPerson.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    services.register(migrations)
}

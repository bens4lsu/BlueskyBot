import Vapor
import Fluent
import FluentMySQLDriver
import QueuesFluentDriver
import Queues

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    let settings = ConfigurationSettings()
    
    var tls = TLSConfiguration.makeClientConfiguration()
    tls.certificateVerification = settings.certificateVerification
    
    app.databases.use(.mysql(
        hostname: settings.database.hostname,
        port: settings.database.port,
        username: settings.database.username,
        password: settings.database.password,
        database: settings.database.database,
        tlsConfiguration: tls
    ), as: .mysql)
    
    app.queues.use(.fluent())
    app.migrations.add(JobMetadataMigrate())
    
    let postJob = BlueskyPostJob()
    
    #if DEBUG
    app.queues.schedule(postJob).minutely().at(5)
    #else
    app.queues.schedule(postJob).daily().at(13, 31)
    #endif
    try app.queues.startScheduledJobs()
    
    let _ = TrackAlreadyPosted()  // so will fail on startup if this json load fails
    
}

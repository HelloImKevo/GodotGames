class_name Logging

## Enhance this so the Multiplayer logger always shows the Client ID of the log message,
## using multiplayer.get_unique_id()

static var mp: LogStream = LogStream.new("Multiplayer", LogStream.LogLevel.INFO)
static var enemy: LogStream = LogStream.new("Enemy", LogStream.LogLevel.INFO)

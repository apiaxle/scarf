class Application
  constructor: ( options ) ->
    # default options
    def =
      env: ( process.env.NODE_ENV or "development" )

    def.name ||= @constructor.name.toLower()

    @final_options = _.extend options, default_options

  readConfiguration: ( )

  run: ( host, port, cb ) ->
    app = express.createServer()

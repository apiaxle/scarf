_ = require "underscore"

class exports.Application
  constructor: ( options={} ) ->
    # default options
    def_opt =
      env: ( process.env.NODE_ENV or "development" )
      name: @constructor.name.toLowerCase()

    # merge the defaults with those we got from the user
    @options = _.extend def_opt, options

    # where to look for the configuration file
    { name, env } = @options
    def_opt.config_paths = [
      "#{ process.env.HOME }/.#{ name }/#{ env }.json"
      "/etc/#{ name }/#{ env }.json"
    ]

  readConfiguration: ( ) ->

  run: ( host, port, cb ) ->
    app = express.createServer()

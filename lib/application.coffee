_ = require "underscore"
fs = require "fs"
validate = require "./validate"

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
    @options.config_filenames ||= [
      "#{ process.env.HOME }/.#{ name }/#{ env }.json"
      "/etc/#{ name }/#{ env }.json"
    ]

  # this should return a valid amanda json schema type document
  getConfigurationSchema: ->
    {} =
      type: "object"
      default: {}

  # returns the err, data (from the parsed file)
  readConfiguration: ( cb ) ->
    for filename in @options.config_filenames
      if fs.existsSync filename
        data = null
        try
          data = JSON.parse( fs.readFileSync( filename ), "utf8" )
        catch e
          return cb new Error "Problem parsing #{filename}: #{e}"

        schema = @getConfigurationSchema()
        return validate schema, data, true, ( err, data ) ->
          return cb null, data, filename

    return cb new Error "Failed to locate a configuration file."

  # run: ( host, port, cb ) ->
  #   app = express.createServer()

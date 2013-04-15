_ = require "lodash"
fs = require "fs"
validate = require "./validate"
readdir = require "recursive-readdir"
express = require "express"

class exports.Application
  constructor: ( options={} ) ->
    # default options
    def_opt =
      env: ( process.env.NODE_ENV or "development" )
      name: @constructor.name.toLowerCase()

    # merge the defaults with those we got from the user
    @options = _.merge def_opt, options

    # where to look for the configuration file
    { name, env } = @options
    @options.config_filenames ||= [
      "#{ process.env.HOME }/.#{ name }/#{ env }.json"
      "/etc/#{ name }/#{ env }.json"
    ]

    @express = express()

  use: ( ) -> @express.use arguments
  param: ( ) -> @express.param arguments
  error: ( ) -> @express.error arguments

  # scan a directory (path) looking for all js/coffee files and then
  # return a map of { name: class } pairs after the file was
  # required. If two classes have the same name then the last one
  # loaded takes presidence.
  collectPlugins: ( path, cb ) ->
    readdir path, ( err, files ) ->
      return cb err if err

      plugin_list = {}
      for filename in files
        continue unless matches = /(.+?)\.(coffee|js)$/.exec filename
        name = matches[1]

        try
          classes = require name

          for cls, func of classes
            plugin_list[ cls ] = func
        catch e
          return cb new Error "Failed to load plugin #{ filename }: #{ e }"

      return cb null, plugin_list

  # json schema for configuration in the config file
  getLoggingConfigSchema: ->
    {}=
      type: "object"
      additionalProperties: false
      properties:
        logging:
          type: "object"
          additionalProperties: false
          properties:
            level:
              type: "string"
              enum: [ "DEBUG", "INFO", "WARN", "FATAL" ]
              default: "INFO"
            appenders:
              type: "array"
              items:
                type: "object"
                additionalProperties: false
                properties:
                  type:
                    type: "string"
                    default: "file"
                  filename:
                    type: "string"
                    default: "#{ @options.env }.log"

  # json schema for the application in the config file
  getAppConfigSchema: ->
    {} =
      type: "object"
      additionalProperties: false
      properties:
        application:
          type: "object"
          additionalProperties: false
          properties:
            port:
              type: "string"
              default: 5000
            host:
              type: "string"
              default: "localhost"

  # all of the configuration combined
  getConfigurationSchema: ->
    _.merge @getAppConfigSchema(), @getLoggingConfigSchema()

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

    tried = @options.config_filenames.join( ", " )
    return cb new Error "Failed to locate a configuration file. Tried #{ tried }."

  setupLogger: ( config, cb ) ->
    config = _.extend default_config, config
    log4js.configure config

    logger = log4js.getLogger()
    logger.setLevel logging_config.level

  # run the application on port, host (defaults to the ones taken from
  # the configuration) the rest of the arguments are passed to
  # @express.listen (http://nodejs.org/api/http.html).
  run: ( port=@config.application.port, host=@config.application.host, rest... ) ->
    @express.listen port, hostname, rest...

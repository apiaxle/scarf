_ = require "lodash"
fs = require "fs"
log4js = require "log4js"
validate = require "./validate"
glob = require "glob"
express = require "express"

class exports.Application
  constructor: ( options={} ) ->
    # default options
    def_opt =
      env: ( process.env.NODE_ENV or "development" )
      name: @constructor.name.toLowerCase()
      port: 5000
      host: "127.0.0.1"

    # merge the defaults with those we got from the user
    @options = _.merge def_opt, options

    # where to look for the configuration file
    { name, env } = @options
    @options.config_filenames ||= [
      "#{ process.env.HOME }/.#{ name }/#{ env }.json"
      "/etc/#{ name }/#{ env }.json"
      "./config/#{env}.json"
    ]

    @express = express()

  set: ( ) -> @express.set arguments...
  use: ( ) -> @express.use arguments...
  param: ( ) -> @express.param arguments...
  error: ( ) -> @express.error arguments...

  # scan a directory (path) looking for all js/coffee files and then
  # return a map of { name: class } pairs after the file was
  # required. If two classes have the same name then the last one
  # loaded takes presidence.
  collectPlugins: ( glob_def, cb ) ->
    glob glob_def, {}, ( err, files ) ->
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
          return cb new Error "Failed to load plugin '#{ filename }': #{ e }"

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
            debug:
              type: "boolean"
              default: false
            debug:
              type: "boolean"
              default: false

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
          return cb err if err
          return cb null, data, filename

    tried = @options.config_filenames.join ", "
    return cb new Error "Failed to locate a configuration file. Tried #{ tried }."

  setupLogger: ( config, cb ) ->
    log4js.configure config

    logger = null
    try
      logger = log4js.getLogger()
      logger.setLevel @config.logging.level
    catch err
      return cb err

    return cb null, logger

  # run the application on port, host (defaults to the ones taken from
  # the options) the rest of the arguments are passed to
  # @express.listen (http://nodejs.org/api/http.html).
  run: ( cb ) ->
    @logger.info "Listening at #{ @options.host}:#{ @options.port }"
    @express.listen @options.port, @options.host, cb

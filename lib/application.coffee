_ = require "underscore"
fs = require "fs"
validate = require "./validate"
readdir = require "recursive-readdir"

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

  # this should return a valid amanda json schema type document
  getConfigurationSchema: ->
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

  setupLogger: ( config, cb ) ->
    config = _.extend default_config, config
    log4js.configure config

    logger = log4js.getLogger()
    logger.setLevel logging_config.level

  # run: ( host, port, cb ) ->
  #   app = express.createServer()

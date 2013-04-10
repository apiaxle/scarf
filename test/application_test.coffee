{ TwerpTest } = require "twerp"
{ Application } = require "../lib/application"

class FakeApplication extends Application

class FakeApplicationConfig extends Application
  getConfigurationSchema: ->
    {} =
      type: "object"
      properties:
        first_name:
          type: "string"
          default: "Bob"
        last_name:
          type: "string"
          required: true

class exports.TestApplication extends TwerpTest
  "test default options": ( done ) ->
    home = process.env.HOME

    @ok app = new FakeApplication()
    @deepEqual app.options,
      name: "fakeapplication"
      env: "development"
      config_filenames: [
        "#{ home }/.fakeapplication/development.json"
        "/etc/fakeapplication/development.json"
      ]

    @ok app = new FakeApplication { env: "staging", name: "bob" }
    @deepEqual app.options,
      name: "bob"
      env: "staging"
      config_filenames: [
        "#{ home }/.bob/staging.json"
        "/etc/bob/staging.json"
      ]

    done 4

  "test loading good configuration": ( done ) ->
    opts =
      config_filenames: [ "./test/config/empty.json" ]

    app = new FakeApplication opts
    app.readConfiguration ( err, config, config_filename ) =>
      @isNull err
      @deepEqual config, {}

      done 2

  "test loading invalid configuration": ( done ) ->
    opts =
      config_filenames: [ "./test/config/invalid.json" ]

    app = new FakeApplication opts
    app.readConfiguration ( err, config, config_filename ) =>
      @ok err
      @match err.message, /SyntaxError/

      done 2

  "test loading empty configuration": ( done ) ->
    opts =
      config_filenames: [ "./test/config/valid.json" ]

    app = new FakeApplicationConfig opts
    app.readConfiguration ( err, config, config_filename ) =>
      @isNull err
      @deepEqual config, { first_name: "Bob", last_name: "Jackson" }

      done 2

{ TwerpTest } = require "twerp"
{ Application } = require "../lib/application"

class FakeApplication extends Application

class exports.TestApplication extends TwerpTest
  "test default options": ( done ) ->
    home = process.env.HOME

    @ok app = new FakeApplication()
    @deepEqual app.options,
      name: "fakeapplication"
      env: "development"
      config_paths: [
        "#{ home }/.fakeapplication/development.json"
        "/etc/fakeapplication/development.json"
      ]

    @ok app = new FakeApplication { env: "staging", name: "bob" }
    @deepEqual app.options,
      name: "bob"
      env: "staging"
      config_paths: [
        "#{ home }/.bob/staging.json"
        "/etc/bob/staging.json"
      ]

    done 1

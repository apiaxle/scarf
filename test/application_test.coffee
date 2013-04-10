{ TwerpTest } = require "twerp"

class exports.TestApplication extends TwerpTest
  "test something": ( done ) ->
    @ok 1

    done 1

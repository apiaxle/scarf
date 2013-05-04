_ = require "lodash"
util = require "util"

class exports.Controller
  @js = []
  @css = []

  constructor: ( @app ) ->
    if not verb = @constructor.verb
      throw new Error "'#{ @constructor.name } needs a http verb."

    if not @path?
      throw new Error "'#{ @constructor.name } needs a path method."

    # convenience to allow setting @locals from middleware
    @locals = {}

    @app.express[ verb ] @path(), @middleware(), ( req, res, next ) =>
      # some helpful locals
      res.locals.title = @constructor.title
      res.locals._ = _
      res.locals.js = @constructor.js
      res.locals.css = @constructor.css
      res.locals.inspect = ( object ) -> util.inspect object, depth: null

      @execute req, res, next

  middleware: -> []

  js: -> []

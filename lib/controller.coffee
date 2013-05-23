_ = require "lodash"
util = require "util"

class exports.Controller
  constructor: ( @app ) ->
    if not verb = @constructor.verb
      throw new Error "'#{ @constructor.name } needs a http verb."

    if not @path?
      throw new Error "'#{ @constructor.name } needs a path method."

    # convenience to allow setting @locals from middleware
    @locals = {}

    @app.express[ verb ] @path(), @middleware(), ( req, res, next ) =>
      @requestHandler req, res, next

  requestHandler: ( req, res, next ) ->
    @execute req, res, next

  middleware: -> []

class exports.ViewController extends exports.Controller
  @js = []
  @css = []

  requestHandler: ( req, res, next )->
    res.locals.title = @constructor.title
    res.locals._ = _
    res.locals.js = @constructor.js
    res.locals.css = @constructor.css
    res.locals.toJson = ( object ) -> JSON.stringify object

    super req, res, next

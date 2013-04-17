_ = require "lodash"
util = require "util"

class exports.Controller
  constructor: ( @app ) ->
    if not verb = @constructor.verb
      throw new Error "'#{ @constructor.name } needs a http verb."

    if not @path?
      throw new Error "'#{ @constructor.name } needs a path method."

    @app.express[ verb ] @path(), @middleware(), ( req, res, next ) =>
      @execute req, res, next

    # convenience to allow setting @locals from middleware
    @locals = @app.express.locals

    # some handy stuff for the templates
    @locals.title = @constructor.title if @constructor.title
    @locals.inspect = util.inspect
    @locals._ = _

    @render = @app.express.render

  middleware: ( ) -> []

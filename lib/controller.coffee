_ = require "lodash"

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
    @locals.title = @constructor.title if @constructor.title
    @locals._ = _

    @render = @app.express.render

  middleware: ( ) -> []

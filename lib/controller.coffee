class exports.Controller
  constructor: ( @app ) ->
    if not verb = @constructor.verb
      throw new Error "'#{ @constructor.name } needs a http verb."

    if not @path?
      throw new Error "'#{ @constructor.name } needs a path method."

    @app.express[ verb ] @path(), @middleware(), ( req, res, next ) =>
      @execute req, res, next

  middleware: ( ) -> []

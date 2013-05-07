_ = require "lodash"

amanda = require "amanda"
jsonSchemaValidator = amanda "json"

# extend the validator with "is_valid_regexp" which tests a string is
# a compilable regular expression
validRegexpAttribute = ( prop, data, value, attrbs, cb ) ->
  return cb() unless value

  try
    new RegExp data
  catch err
    @addError err

  return cb()

jsonSchemaValidator.addAttribute "is_valid_regexp", validRegexpAttribute

# extract the default values into their own object
extractDefaults = ( name, structure ) ->
  if structure.type is "object" and structure.properties?
    out = {}

    for property, details of structure.properties
      val = extractDefaults property, details
      out[property] = val if val isnt undefined

    return out

  if structure.type is "array" and structure.items?
    out = extractDefaults null, structure.items
    return [ out ]

  # no default and it's not an object
  return undefined unless structure.default?

  # we've got a value
  return structure.default

# validate `data` against JSON schema `struct`. Returns array of
# errors if there are any and will pad the structure with defaults if
# `fill_defaults` is set to true
module.exports = ( structure, data, fill_defaults, cb ) ->
  jsonSchemaValidator.validate data, structure, ( errs ) ->
    message = []
    for index, err of errs
      message.push err.message if err.message

      # additional props need special handling
      if err.validator is "additionalProperties"
        message.push "'#{ err.property }' is not a supported field."

    return cb new Error( message.join( ", " ) ) if err

    # perhaps fill defaults
    return cb null, structure.properties unless fill_defaults

    merged_defaults = _.merge( extractDefaults( null, structure ), data )
    return cb null, merged_defaults

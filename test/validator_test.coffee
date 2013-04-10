{ TwerpTest } = require "twerp"
validate = require "../lib/validate"

class exports.TestValidator extends TwerpTest
  "test simple structure": ( done ) ->
    @ok validate

    schema =
      type: "object"
      additionalProperties: false
      properties:
        name:
          type: "string"
          default: "fred"

    validate schema, { name: "bob" }, true, ( err, structure ) =>
      @isNull err
      @deepEqual { name: "bob" }, structure

      done 3

  "test more complicated structure": ( done ) ->
    @ok validate

    schema =
      type: "object"
      additionalProperties: false
      properties:
        name:
          type: "string"
          required: true
        address:
          type: "object"
          additionalProperties: false
          properties:
            street:
              type: "string"
              required: true
            country:
              type: "string"
              enum: ["uk", "us"]
              default: "uk"

    data =
      name: "Bannanaman"
      address:
        street: "29 Acacia Road"
        country: "uk"

    validate schema, data, true, ( err, structure ) =>
      @isNull err
      @deepEqual data, structure

      done 3

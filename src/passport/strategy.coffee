#
#Module dependencies.
#

#
#`Strategy` constructor.
#
#The FreeAgent authentication strategy authenticates requests by delegating to
#FreeAgent using the OAuth 2.0 protocol.
#
#Options:
#- `clientID`      your FreeAgent application's Client ID
#- `clientSecret`  your FreeAgent application's Client Secret
#- `callbackURL`   URL to which FreeAgent will redirect the user after granting authorization
#
#@param {Object} options
#@param {Function} verify
#@api public
#
InternalOAuthError = undefined
OAuth2Strategy = undefined
Strategy = undefined
util = undefined

baseUri = "https://api.freeagent.com/v2/"

Strategy = (options, verify) ->
  options = options or {}
  options.authorizationURL = options.authorizationURL or baseUri + "approve_app"
  options.tokenURL = options.tokenURL or baseUri + "token_endpoint"
  options.scopeSeparator = options.scopeSeparator or ","
  OAuth2Strategy.call this, options, verify
  @name = "freeagent"

util = require("util")
OAuth2Strategy = require("passport-oauth").OAuth2Strategy
InternalOAuthError = require("passport-oauth").InternalOAuthError

#
#Inherit from `OAuth2Strategy`.
#
util.inherits Strategy, OAuth2Strategy

#
#Retrieve user profile from FreeAgent.
#
#@param {String} accessToken
#@param {Function} done
#
Strategy::userProfile = (accessToken, done) ->
  @_oauth2._request "GET", baseUri + "users/me",
    "User-Agent": "passport-freeagent2"
    "Authorization": "Bearer #{accessToken}"
  , null, accessToken, (err, body, res) ->
    json = undefined
    return done(new InternalOAuthError("failed to fetch user profile", err))  if err
    try
      json = JSON.parse(body)
      json.provider = "FreeAgent"
      return done(null, json.user)
    catch e
      return done(e)

#
#Expose `Strategy`.
#
module.exports = Strategy
# Description:
#   Post hott videos to tumblr.
#
# Author:
#   awentzonline adapted from onionbot script by csinchok

tumblr = require "tumblr.js"

config =
  consumerKey: process.env.TUMBLR_CONSUMER_KEY
  consumerSecret: process.env.TUMBLR_CONSUMER_SECRET
  accessToken: process.env.TUMBLR_ACCESS_TOKEN
  accessTokenSecret: process.env.TUMBLR_ACCESS_TOKEN_SECRET
  blogName: process.env.TUMBLR_BLOG_NAME

unless config.consumerKey
  console.log "Please set the TUMBLR_CONSUMER_KEY environment variable."
unless config.consumerSecret
  console.log "Please set the TUMBLR_CONSUMER_SECRET environment variable."
unless config.accessToken
  console.log "Please set the TUMBLR_ACCESS_TOKEN environment variable."
unless config.accessTokenSecret
  console.log "Please set the TUMBLR_ACCESS_TOKEN_SECRET environment variable."
unless config.blogName
  console.log "Please set the TUMBLR_BLOG_NAME environment variable."

tumblrClient = tumblr.createClient
  consumer_key: config.consumerKey,
  consumer_secret: config.consumerSecret,
  token: config.accessToken,
  token_secret: config.accessTokenSecret

recentlyPosted = {}  # this could be better

module.exports = (robot) ->
  # includes the trailing space for neater trimming below
  robot.hear /(?:https?:\/\/)?(?:youtu\.be\/|(?:www\.)?youtube\.com\/watch(?:\.php)?\?.*v=)([a-zA-Z0-9\-_]+)[^\s]*\s*/, (res) ->
    fullUrl = res.match[0]
    videoId = res.match[1]
    if recentlyPosted[videoId]
      return
    # remove the url from the input
    message = res.match.input.replace fullUrl, ""
    message = message.trim()
    # make sure there's a caption or tumblr gets upset
    if !message
      return
    # trailing whitespace is included in the url so we dont end
    # up with double spaces in the message
    fullUrl = fullUrl.trim()
    options =
      embed: fullUrl,
      caption: message
    tumblrClient.video config.blogName, options, (error, response) ->
      if error
        res.send "Error posting #{fullUrl} to #{config.blogName}: #{error}"
      else
        res.send "Posted to #{config.blogName}"
        recentlyPosted[videoId] = new Date()

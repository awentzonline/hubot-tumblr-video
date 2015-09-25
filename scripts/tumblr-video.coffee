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
  robot.hear /(?:https?:\/\/)?(?:youtu\.be\/|(?:www\.)?youtube\.com\/watch(?:\.php)?\?.*v=)([a-zA-Z0-9\-_]+)\s*/, (res) ->
    fullUrl = res.match[0]
    videoId = res.match[1]
    if recentlyPosted[videoId]
      return
    message = res.match.input.replace res.match[0], ""
    options =
      embed: fullUrl,
      caption: message
    tumblrClient.video config.blogName, options, (error, response) ->
      if error
        res.send "Error posting #{fullUrl} to #{config.blogName}: #{error}"
      else
        res.send "New fart: http://turdward.tumblr.com/post/#{response.id}/"
        recentlyPosted[videoId] = new Date()

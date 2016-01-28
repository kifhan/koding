kd                        = require 'kd'
React                     = require 'kd-react'
ReactDOM                  = require 'react-dom'
createHistory             = require 'history/lib/createHistory'
createLocation            = require 'history/lib/createLocation'
handlers                  = require './routehandlers'
lazyrouter                = require 'app/lazyrouter'
isFeedEnabled             = require 'app/util/isFeedEnabled'
{ RoutingContext, match } = require 'react-router'

reactivityRouteTypes = [
  'NewPublicChannel'
  'AllPublicChannels'
  'SinglePublicChannel'
  'SinglePublicChannelPost'
  'SinglePublicChannelRecentMessages'
  'SinglePublicChannelPopularMessages'
  'PublicChannelNotificationSettingsRoute'

  'PrivateChannelModals'
  'PublicChannelModals'
  'NewPrivateChannel'
  'AllPrivateChannels'
  'SinglePrivateChannel'
  'SinglePrivateChannelPost'
]

module.exports = -> lazyrouter.bind 'activity', (type, info, state, path, ctx) ->

  handle = (name) -> handlers["handle#{name}"](info, ctx, path, state)

  # since `isFeedEnabled` flag checks roles from config,
  # wait for mainController to be ready to call `isFeedEnabled`
  # FIXME: Remove this call before public release. ~Umut
  kd.singletons.mainController.ready ->
    if type in reactivityRouteTypes
      if not isKoding() or isFeedEnabled()
      then handleReactivity info, ctx
      # unless reactivity is enabled redirect reactivity routes to `Public`
      else ctx.handleRoute '/Activity/Public'
    else handle type


###*
 * Renders with reacth router.
###
handleReactivity = ({ query }, router) ->

  routes = require './reactivityroutes'

  location = createLocation router.currentPath

  activityView (view) ->

    match { routes, location }, (err, redirectLocation, renderProps) ->
      ReactDOM.render(
        <RoutingContext {...renderProps} />
        view.reactivityContainer.getElement()
      )


activityView = (callback) ->
  {appManager} = require('kd').singletons
  appManager.open 'Activity', (app) ->
    view = app.getView()
    view.switchToReactivityContainer()
    callback view

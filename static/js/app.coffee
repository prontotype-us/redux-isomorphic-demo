React = require 'preact'
Kefir = require 'kefir'
KefirBus = require 'kefir-bus'
fetch$ = require 'kefir-fetch'
{Router, Resolver} = require 'zamba-router'
Store = require './store'

# Set up router and resolver
# ------------------------------------------------------------------------------

{routes, loaders} = require './twitter-spec'
components = require './components'

router = new Router routes
resolver = new Resolver loaders

# Dispatcher to allow subscribing to actions

Dispatcher =
    actions$: KefirBus()
    dispatch: (action) ->
        Dispatcher.actions$.emit action
Dispatcher.actions$
    .log 'actions$'
    .onValue (action) ->
        Store.dispatch action

navigate$ = Dispatcher.actions$
    .filter (action) -> action.type == 'app.navigate'

# Specific dispatcher methods that happen when navigation changes

Dispatcher.getUser = ({username}) ->
    Dispatcher.dispatch {type: 'user.loading'}
    loaders.getUser({username}).onValue ({user}) ->
        Dispatcher.dispatch {type: 'user.loaded', user}

Dispatcher.findFeedTweets = ->
    Dispatcher.dispatch {type: 'feed_tweets.loading'}
    loaders.findFeedTweets().onValue ({items}) ->
        Dispatcher.dispatch {type: 'feed_tweets.loaded', items}

Dispatcher.findUserTweets = ({username}) ->
    Dispatcher.dispatch {type: 'user_tweets.loading'}
    loaders.findUserTweets({username}).onValue ({items}) ->
        Dispatcher.dispatch {type: 'user_tweets.loaded', items}

Dispatcher.findUserFavorites = ({username}) ->
    Dispatcher.dispatch {type: 'user_favorites.loading'}
    loaders.findUserFavorites({username}).onValue ({items}) ->
        Dispatcher.dispatch {type: 'user_favorites.loaded', items}

navigate$
    .filter (action) ->
        action.params.username != Store.getState().user_page.user?.username
    .log '**** **** user changed'
    .onValue (action) -> Dispatcher.getUser action.params

navigate$
    .filter (action) ->
        action.route.name == 'FeedPage'
    .onValue (action) -> Dispatcher.findFeedTweets action.params

navigate$
    .filter (action) ->
        action.route.name == 'UserTweets'
    .onValue (action) -> Dispatcher.findUserTweets action.params

navigate$
    .filter (action) ->
        action.route.name == 'UserFavorites'
    .onValue (action) -> Dispatcher.findUserFavorites action.params

# Navigation control with history

navigate = (path) ->
    console.log '[navigate]', path
    if matched = router.matchPath path
        {route, params} = matched
        Dispatcher.dispatch {type: 'app.navigate', path, route, params}

history = require './history'
history.listen (location, action) ->
    console.log '[history.listen]', location, action
    navigate location.pathname

# Main container watching store state and rendering app

class Container extends React.Component
    constructor: ->
        @state = Store.getState()
        Store.subscribe =>
            @setState Store.getState()

    render: ->
        console.log '[Container.render]', @state
        if @state.app.route?
            @renderRoute()
        else
            <em>Loading route...</em>

    # Rendering a route (from the leaf to the root App component)
    renderRoute: ->
        component_list = router.componentsForRoute @state.app.route
        console.log '[renderRoute]', @state, component_list
        for component_name in component_list
            Component = components[component_name]
            child = React.createElement Component, @state, child
        return child

$app = document.getElementById 'app'
$app.innerHTML = ''
React.render <Container />, $app

Redux = require 'redux'

# Setting up Redux store
# ------------------------------------------------------------------------------

app = (state={}, action) ->
    switch action.type
        when 'app.navigate'
            {path, route, params} = action
            return Object.assign {}, state, {path, route, params}
    return state

auth = (state={}, action) ->
    return state

feed_tweets = (state={}, action) ->
    switch action.type
        when 'feed_tweets.loading'
            return Object.assign {}, state, {loading: true}
        when 'feed_tweets.loaded'
            return Object.assign {}, state, {loading: false, items: action.items}
    return state

user_page = (state={}, action) ->
    switch action.type
        when 'user.loading'
            return Object.assign {}, state, {loading: true}
        when 'user.loaded'
            return Object.assign {}, state, {loading: false, user: action.user}
    return state

user_tweets = (state={}, action) ->
    switch action.type
        when 'user_tweets.loading'
            return Object.assign {}, state, {loading: true}
        when 'user_tweets.loaded'
            return Object.assign {}, state, {loading: false, items: action.items}
    return state

user_favorites = (state={}, action) ->
    switch action.type
        when 'user_favorites.loading'
            return Object.assign {}, state, {loading: true}
        when 'user_favorites.loaded'
            return Object.assign {}, state, {loading: false, items: action.items}
    return state

reducers = Redux.combineReducers {app, auth, feed_tweets, user_page, user_tweets, user_favorites}
module.exports = Store = Redux.createStore reducers, initial_state

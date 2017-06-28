Kefir = require 'kefir'

# Helpers
# ------------------------------------------------------------------------------

# Turn an object into a randomly delayed kefir stream
delay = (o) -> Kefir.later Math.random() * 1000, o

randomChoice = (l) -> l[Math.floor Math.random() * l.length]

users = ['joe', 'fred', 'sam', 'kathy']

# Routes and loader dependencies
# ------------------------------------------------------------------------------

routes =
    path: '/'
    load:
        auth: 'getAuth'
    children:
        FeedPage:
            path: ''
            load:
                feed_tweets: 'findFeedTweets'
        UserPage:
            path: '/users/:username'
            load:
                user_page: 'getUser'
            children:
                UserTweets:
                    path: '/'
                    load:
                        user_tweets: 'findUserTweets'
                UserFavorites:
                    path: '/favorites'
                    load:
                        user_favorites: 'findUserFavorites'
        SettingsPage:
            path: '/settings'

# Loaders
# ------------------------------------------------------------------------------

loaders =
    getAuth: -> delay {
        user: {username: "tester", name: "The Tester"}
    }
    getUser: ({username}) -> delay {
        user: {username, name: "Jones"}
    }
    findFeedTweets: -> delay {
        items: [
            {body: 'dramatic fact', username: randomChoice(users)}
            {body: 'pointless ad', username: randomChoice(users)}
        ]
    }
    findUserTweets: ({username}) -> delay {
        items: [
            {body: 'im ' + username, username}
            {body: 'i like tests', username}
        ]
    }
    findUserFavorites: -> delay {
        items: [
            {body: 'funny joke', username: randomChoice(users)}
            {body: 'good picture', username: randomChoice(users)}
        ]
    }

module.exports = {
    routes
    loaders
}

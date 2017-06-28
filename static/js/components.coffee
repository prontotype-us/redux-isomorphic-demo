React = require 'preact'
if window?
    history = require './history'
    window._history = history

React.__spread = Object.assign

# Components (all stateless)
# ------------------------------------------------------------------------------

App = ({app, auth, children}) ->
    <div className='app'>
        <h1><Link to='/'>app</Link></h1>
        <p>Logged in as {auth.user.username}</p>
        <code>path = {app.path}</code>
        {children}
    </div>

ErrorPage = ({app}) ->
    <p>Error getting <code>{app.path}</code></p>

Link = ({to, children, active, app}) ->
    active ||= app?.path == to
    onClick = (e) ->
        e.preventDefault()
        e.stopPropagation()
        if to != history.location.pathname
            history.push to
    if active
        <strong>{children}</strong>
    else
        <a href=to onClick=onClick>{children}</a>

FeedPage = ({feed_tweets}) ->
    <div className='tweets'>
        <h2>Feed</h2>
        {if feed_tweets.loading
            <em>Loading tweets...</em>
        else if not feed_tweets.items.length
            <em>Empty tweets</em>
        else
            feed_tweets.items.map (tweet) ->
                <Tweet {...tweet} key=tweet.id />
        }
    </div>

UserPage = ({app, user_page, children}) ->
    <div className='user-page'>
        {if user_page.loading
            <em>Loading user...</em>
        else
            <div>
                <p>Looking at {user_page.user.username}</p>
                <p>Look at
                    <Link to="/users/jones" active={app.params.username == 'jones'}>jones</Link>
                    <Link to="/users/fred" active={app.params.username == 'fred'}>fred</Link>
                </p>
                <div className='tabs'>
                    <Link to="/users/#{user_page.user.username}" app=app>Tweets</Link>
                    <Link to="/users/#{user_page.user.username}/favorites" app=app>Favorites</Link>
                </div>
                {children}
            </div>
        }
    </div>

UserTweets = ({user_tweets}) ->
    <div className='user-tweets'>
        <h2>Tweets</h2>
        {if user_tweets.loading
            <em>Loading tweets...</em>
        else if not user_tweets.items.length
            <em>Empty tweets</em>
        else
            user_tweets.items.map (tweet) ->
                <Tweet {...tweet} key=tweet.id />
        }
    </div>

UserFavorites = ({user_favorites}) ->
    <div className='user-favorites'>
        <h2>Favorites</h2>
        {if user_favorites.loading
            <em>Loading favorites...</em>
        else if not user_favorites.items.length
            <em>Empty favorites</em>
        else
            user_favorites.items.map (tweet) ->
                <Tweet {...tweet} key=tweet.id />
        }
    </div>

Tweet = ({username, body}) ->
    <div className='tweet'>
        <Link to="/users/#{username}">{username}</Link>
        <p className='body'>{body}</p>
    </div>

module.exports = {
    App
    FeedPage
    UserPage
    UserTweets
    UserFavorites
    ErrorPage
}

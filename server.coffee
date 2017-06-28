polar = require 'polar'
React = require 'preact'
render = require 'preact-render-to-string'
{Router, Resolver} = require 'zamba-router'
require('coffee-react/register')

# Set up router and resolver
# ------------------------------------------------------------------------------

components = require './static/js/components'
twitter = require './static/js/twitter-spec'
router = new Router twitter.routes
resolver = new Resolver twitter.loaders

class Container extends React.Component
    render: ->
        component_list = router.componentsForRoute @props.app.route
        for component_name in component_list
            Component = components[component_name]
            child = React.createElement Component, @props, child
        return child

renderIsomorphic = (req, res) ->
    console.log 'get path', req.url
    path = req.url
    if matched = router.matchPath path
        {route, params} = matched
        console.log '[matched]', path, {route, params}, components

        resolver.resolveRoute {route, params}
            .onValue (resolved) ->
                initial_state = Object.assign {app: {path, route, params}}, resolved
                html = render(React.createElement Container, initial_state)
                return res.render 'index', {html, initial_state}

    else
        # TODO: Render 404
        console.error '404'

# Create polar app
# ------------------------------------------------------------------------------

app = polar port: 4337, static_dir: 'static'

# Render on specific routes (to avoid clobbering static routes)
for route in Object.keys router.routes
    app.get route, renderIsomorphic

app.start()

# Attach page slugs to page view classes
attagePageSlugs = (pages) ->
    _.pairs(pages).map ([page_slug, page_view]) ->
        page_view.page_slug = page_slug

# Generate a function that opens a page on the app view
pageSetter = (page_view, app_view) ->
    -> app_view.setState page: page_view

# Generate a set of routes for the router
makeRoutes = (pages) ->
    page_slugs = _.keys(pages)
    routes = _.extend(
        _.object(_.zip(page_slugs, page_slugs)), # Routes are just page slugs
        {'': page_slugs[0]} # First page is default route
    ) # Returns an object of {route: page_slug, ...}

# Generate a set of routing functions
makeActions = (pages, app_view) ->
    actions = _.object(
        _.pairs(pages).map ([page_slug, page_view]) ->
            [page_slug, pageSetter(page_view, app_view)]
    ) # Returns an object of {page_slug: page_view, ...}

# Generate a router class
window.PageRouter = (pages, app_view) ->
    attagePageSlugs(pages)
    page_routes = makeRoutes(pages)
    page_actions = makeActions(pages, app_view)
    router_extension = _.extend {routes: page_routes}, page_actions
    Backbone.Router.extend router_extension


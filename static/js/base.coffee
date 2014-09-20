pages =
    services: ServicesView
    shell: ShellView
    docs: DocsView

# TODO: Still not perfectly decoupled but I'm not sure where to make the divide
app_view = React.renderComponent(
    AppView(page_slugs: _.keys(pages))
, $('#main')[0])

window.router = new (PageRouter pages, app_view)
Backbone.history.start()


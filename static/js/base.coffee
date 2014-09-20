pages =
    services: ServicesView
    shell: ShellView
    docs: DocsView

window.router = new (PageRouter pages)
window.app_view = React.renderComponent(
    AppView(router: router)
, $('#main')[0])

Backbone.history.start()


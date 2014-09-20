D = React.DOM

window.DocsView = React.createClass

    render: ->
        D.div(id: 'docs',
            D.h1(null, "API Documentation")
            D.p(null, "Some docs could be nice.")
        )


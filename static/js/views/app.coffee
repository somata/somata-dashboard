D = React.DOM

console.log "Starting app..."

window.AppView = React.createClass

    render: ->
        return D.div(null) if !@state?.page

        return D.div(null,
            D.div(id: 'nav', @renderPagesNav())
            D.div(className: 'box', @renderPageContent())
        )

    renderPagesNav: ->
        selected_page_name = @state.page.page_slug
        
        pages = @props.page_slugs.map (p) -> # Create a link for each page slug
            selectedClass = if p == selected_page_name then 'selected' else ''
            D.a(key: p, className: selectedClass, href: '#' + p, p)

        return [LogoView(key: 'logo')].concat pages # Prepend the logo

    renderPageContent: ->
        return @state.page()

LogoView = React.createClass
    render: ->
        return D.img(className: 'logo', src: "/images/somata-logo.svg")


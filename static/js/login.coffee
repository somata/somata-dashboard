React = require 'react'
ReactDOM = require 'react-dom'
{LoginPage} = require 'react-zamba/lib/login'

ReactDOM.render <LoginPage hide_signup=true />, document.getElementById('app')


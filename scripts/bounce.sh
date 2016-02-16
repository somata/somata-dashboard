PORT=${1:-20815}
BASE=${2:-app/static}
rm $BASE/{css,js}/{app,login}.bounced.*
curl -o $BASE/js/app.bounced.js localhost:$PORT/js/app.js -H "X-Enable-Bouncer: true"
curl -o $BASE/css/app.bounced.css localhost:$PORT/css/app.css -H "X-Enable-Bouncer: true"
curl -o $BASE/js/login.bounced.js localhost:$PORT/js/login.js -H "X-Enable-Bouncer: true"
curl -o $BASE/css/login.bounced.css localhost:$PORT/css/login.css -H "X-Enable-Bouncer: true"

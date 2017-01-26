const app = require('express')()
app.get('/', (req, res) => { res.send('I live!').end() })
app.listen(3000)

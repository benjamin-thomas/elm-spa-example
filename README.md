# Blog tutorial

Following tutorial at: https://medium.com/@grrinchas/building-a-single-page-application-in-elm-planning-and-scaffolding-part-2-279b4924c578


## Run dev server

`--hot` restores the previous app state after reload, `--pushstate` serves all requests with start-page (required behavior for `Browser.application`).
```bash
elm-live ./src/Main.elm --start-page=index2.html --hot --pushstate -- --debug --output=dist/main.js
```
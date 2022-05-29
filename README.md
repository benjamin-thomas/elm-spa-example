# Blog tutorial

Original tutorial found at: https://medium.com/@grrinchas/building-a-single-page-application-in-elm-planning-and-scaffolding-part-2-279b4924c578

It was designed prior to Elm `0.19.1` so it mostly served as inspiration from early implementations.

## Objectives

- demonstrate routing (as a SPA)
- use type safe routing
- validate user data (forms)
- reload form state from the URL
- explore how to organize code

## Requirements

Basic elm toolchain and `elm-live`.


## Run dev server

`--hot` restores the previous app state after reload, `--pushstate` serves all requests with start-page (required behavior for `Browser.application`).
```bash
# Frontend
elm-live ./src/Main.elm --start-page=index2.html --hot --pushstate -- --debug --output=dist/main.js
```

## Backend

See:

- https://jsonplaceholder.typicode.com/guide/
- https://github.com/typicode/json-server#paginate


Example usage:
```
http https://jsonplaceholder.typicode.com/posts _limit==2 _page==2
```

# Elm SPA example

Original tutorial found at: https://medium.com/@grrinchas/building-a-single-page-application-in-elm-planning-and-scaffolding-part-2-279b4924c578

It was designed prior to Elm `0.19.1` so it mostly served as inspiration from early implementations.

## Deployment

The live app is available at: https://benjamin-thomas.github.io/elm-spa-example/gh/

## Objectives

- demonstrate SPA routing techniques
- use type safe routing
- validate user data (forms)
- GET and POST data via a JSON API
- explore how to organize code

## TODO

- reload form state from the URL (TODO)
- remove CSS framework and implement custom styles


## Requirements

Basic elm toolchain and `elm-live`.

## Misc

I use hash based routing (via `mthadley/elm-hash-routing`) so that I can deploy this app easily to github pages.


## Run dev server

```bash
# Frontend
elm-live ./src/Main.elm --start-page=index2.html --hot -- --debug --output=dist/main.js
```

## Backend

Live backend is freely accessible at: https://jsonplaceholder.typicode.com/posts?_limit=2&_page=2

Note that the PUT, POST, PATCH and DELETE methods only simulate modifying the underlying resource.

See also:

- https://jsonplaceholder.typicode.com/guide/
- https://github.com/typicode/json-server#paginate
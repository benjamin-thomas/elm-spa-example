# Blog tutorial

Following tutorial at: https://medium.com/@grrinchas/building-a-single-page-application-in-elm-planning-and-scaffolding-part-2-279b4924c578

## Requirements

```bash
npm install -g json-server
http --help # httpie
```


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
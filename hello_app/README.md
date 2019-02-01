# Hello App

Simple Sintra service that says Hello!

## Build, run and test manually

```shell
$ docker build -t hello:latest .
$ docker run -p 4567 hello:latest
$ curl http://localhost:4567/hello
$ curl http://localhost:4567/hello?name=JD
```

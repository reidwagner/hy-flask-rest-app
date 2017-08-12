# Sample Flask REST tasklist written in Hy

Rewrote in [Hy](http://docs.hylang.org/en/stable/) and with sqlite support the app built in [this tutorial](https://blog.miguelgrinberg.com/post/designing-a-restful-api-with-python-and-flask). Hy is a Lisp dialect that compiles into Python AST.

You'll need to set up a sqlite database in the directory named tasks.db and create this table: <code>CREATE TABLE task(id smallint, title varchar(20), description varchar(200), done smallint);</code>

To run:
```shell
./main.py
```

To try it out:
```shell
curl -i -u foo:bar -X GET 127.0.0.1:5000/todo/api/v1.0/tasks
curl -i -u foo:bar -X GET 127.0.0.1:5000/todo/api/v1.0/tasks/1
curl -i -u foo:bar -X POST -H "Content-Type: application/json" 127.0.0.1:5000/todo/api/v1.0/tasks -d '{"title": "buy milk"}'
curl -i -u foo:bar -X PUT -H "Content-Type: application/json" 127.0.0.1:5000/todo/api/v1.0/tasks/2 -d '{"done":true}'
curl -i -u foo:bar -X DELETE 127.0.0.1:5000/todo/api/v1.0/tasks/2
```

Sources:
* https://blog.miguelgrinberg.com/post/designing-a-restful-api-with-python-and-flask
* https://github.com/hylang/shyte - Used hack from here to get flask started.

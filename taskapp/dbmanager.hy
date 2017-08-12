#!/usr/bin/env hy

(import sqlite3)
(import [flask [g]])

(setv DATABASE "tasks.db")

(defn get-db []
    (setv db (getattr g "_database" None))
    (if (= db None)
        (do
        (setattr g "_database" (.connect sqlite3 DATABASE))
        (setv db (getattr g "_database"))))
    db)

(defn close-db []
    (setv db (getattr g "_database" None))
    (if (= db None)
        (.close db)))

(defn record-to-dict [fields values]
    (dict (zip fields values)))

(defn query-db [query &optional [args ()] [one False]]
    (setv conn (get-db))
    (setv curs (.cursor conn))
    (.execute curs query args)
    (setv rv (.fetchall curs))
    (.commit conn)
    (.close curs)
    (if one
        (if rv
            (get rv 0)
            None)
        rv))

(defn retrieve-task [task-id]
    (record-to-dict 
        (, "id" "title" "description" "done")
        (query-db "SELECT * FROM task WHERE id = ?" :args (, task-id) :one True)))

(defn retrieve-last-task []
    (record-to-dict 
        (, "id" "title" "description" "done")
        (get (query-db "SELECT * FROM task ORDER BY id DESC LIMIT 1") 0)))

(defn retrieve-all-tasks []
    (list-comp
     (record-to-dict
        (, "id" "title" "description" "done")
        task)
     (task (query-db "SELECT * FROM task"))))

(defn delete-task [task-id]
    (query-db "DELETE FROM task where id = ?" (, task-id)))

(defn create-task [task-id title description done]
    (query-db "INSERT INTO task VALUES (?, ?, ?, ?)" (, task-id title description done)))

(defn update-task [task-id title description done]
    (print task-id title description done)
    (query-db "UPDATE task SET title = ?, description = ?, done = ? where id = ?" (, title description done task-id)))

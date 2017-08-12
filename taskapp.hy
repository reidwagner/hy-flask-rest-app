#!/usr/bin/env hy

(import [flask [Flask
                jsonify
                make_response
                abort
                request
                g]])
(import [flask_httpauth [HTTPBasicAuth]])
(import [dbmanager :as dbm])

(setv auth (HTTPBasicAuth))
(setv app (Flask "__main__"))

#@(auth.get-password
(defn get-password [username]
    (if (= username "foo")
        "bar"
        None)))

#@(app.teardown_appcontext
(defn close-connection [exception]
    dbm.close-db()))

(defn retrieve-request-json []
    (setv request-json (.get-json request))
    (if request-json
        request-json
        (abort 400))) 

#@((app.route "/todo/api/v1.0/tasks" :methods ["GET"]) auth.login-required
(defn get-tasks-route []
   (setv task (.retrieve-all-tasks dbm))
   (jsonify {"tasks" task})))

#@((app.route "/todo/api/v1.0/tasks/<int:task_id>" :methods ["GET"]) auth.login-required
(defn get-task [task-id]
   (setv task (.retrieve-task dbm task-id))
   (jsonify {"tasks" task})))

#@((app.route "/todo/api/v1.0/tasks" :methods ["POST"]) auth.login-required
(defn create-task-route []
    (setv request-json (retrieve-request-json))
    (if (not (and request-json (in "title" request-json)))
        (abort 404))
    (setv last-task (.retrieve-last-task dbm))
    (.create-task dbm
        (+ 1 (get last-task "id"))                  ; id
        (get request-json "title")                  ; title
        (.get request-json "description" "")        ; description
        (if (.get request-json "done" False) 1 0))  ; done
    (jsonify {"result" "Success"})))

#@((app.route "/todo/api/v1.0/tasks/<int:task_id>" :methods ["PUT"]) auth.login-required
(defn update-task-route [task-id]
    (setv task (.retrieve-task dbm task-id))
    (setv request-json (retrieve-request-json))
    (print (.get request-json "done"))
    (.update-task dbm
        task-id
        (.get request-json "title" (get task "title"))
        (.get request-json "description" (get task "description"))
        (.get request-json "done" (get task "done")))
    (jsonify {"result" "Success"})))

#@((app.route "/todo/api/v1.0/tasks/<int:task_id>" :methods ["DELETE"]) auth.login-required
(defn delete-task-route [task-id]
    (.delete-task dbm task-id)
    (jsonify {"result" "Success"})))

#@(auth.error-handler
(defn unauthorized []
    (make-response (jsonify {"error" "Unauthorized access"}) 401)))

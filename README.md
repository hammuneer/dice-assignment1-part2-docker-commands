# Assignment 1 – Part 2: Docker Containers with Commands

**Author:** hammuneer
**GitHub repository:** https://github.com/hammuneer/dice-assignment1-part2-docker-commands
**Docker image used:** [`hammuneer/dice-docker-demo:1.0.0`](https://hub.docker.com/r/hammuneer/dice-docker-demo) (built and pushed in Part 1)
**Part 1 repository:** https://github.com/hammuneer/dice-assignment1-part1-docker

This repository documents how to manage the lifecycle of a Docker container with the Docker CLI.
Every command required by the assignment was run against the image from Part 1. For each
command, this README gives a short description, the exact command and the real output it
produced. The raw output of every command is also saved in the [`logs/`](logs) folder.

### Summary

| Step | Task | Marks | Result |
|------|------|-------|--------|
| 1 | Use the Docker image from Part 1 | 5 | `hammuneer/dice-docker-demo:1.0.0` pulled from Docker Hub ([Step 1](#step-1--use-the-docker-image-from-part-1)) |
| 2 | Run the container and verify the app | 20 | Container running on port 8080, API and frontend respond ([Step 2](#step-2--run-the-docker-container)) |
| 3 | Use the different container commands | 20 | All 20 commands executed ([Step 3](#step-3--docker-container-commands)) |
| 4 | Document the results in README.md | 25 | This document plus raw logs in [`logs/`](logs) |
| 5 | Push the codebase to a new GitHub repository | – | Pushed to `main` ([Step 5](#step-5--push-the-codebase-to-github)) |

### Environment

| Tool | Version |
|------|---------|
| Docker Engine / CLI | 29.2.1 (Docker Desktop on macOS) |
| Git | 2.50.1 |
| GitHub CLI (`gh`) | 2.101.0 |

---

## Table of Contents

1. [The sample application](#the-sample-application)
2. [Step 1 – Use the Docker image from Part 1](#step-1--use-the-docker-image-from-part-1)
3. [Step 2 – Run the Docker container](#step-2--run-the-docker-container)
4. [Step 3 – Docker container commands](#step-3--docker-container-commands)
   - [3.1 `docker ps`](#31-docker-ps--list-running-containers)
   - [3.2 `docker logs`](#32-docker-logs--view-the-logs-of-a-container)
   - [3.3 `docker inspect`](#33-docker-inspect--view-the-details-of-a-container)
   - [3.4 `docker exec`](#34-docker-exec--run-a-command-inside-a-running-container)
   - [3.5 `docker top`](#35-docker-top--view-the-processes-running-inside-a-container)
   - [3.6 `docker stats`](#36-docker-stats--view-the-resource-usage-of-containers)
   - [3.7 `docker port`](#37-docker-port--show-the-public-facing-port-mapping)
   - [3.8 `docker cp`](#38-docker-cp--copy-files-between-the-container-and-the-host)
   - [3.9 `docker commit`](#39-docker-commit--create-a-new-image-from-a-container)
   - [3.10 `docker attach` (to a running container)](#310-docker-attach--attach-to-a-running-container)
   - [3.11 `docker pause`](#311-docker-pause--pause-a-running-container)
   - [3.12 `docker unpause`](#312-docker-unpause--unpause-a-paused-container)
   - [3.13 `docker rename`](#313-docker-rename--rename-a-container)
   - [3.14 `docker update`](#314-docker-update--update-a-containers-resource-limits)
   - [3.15 `docker restart`](#315-docker-restart--restart-a-running-container)
   - [3.16 `docker stop`](#316-docker-stop--stop-a-running-container)
   - [3.17 `docker start`](#317-docker-start--start-a-stopped-container)
   - [3.18 `docker attach` (stdin, stdout and stderr)](#318-docker-attach--attach-local-stdin-stdout-and-stderr)
   - [3.19 `docker wait`](#319-docker-wait--wait-for-a-container-to-exit-and-show-its-exit-code)
   - [3.20 `docker rm`](#320-docker-rm--remove-a-stopped-container)
5. [Step 4 – Findings and observations](#step-4--findings-and-observations)
6. [Step 5 – Push the codebase to GitHub](#step-5--push-the-codebase-to-github)
7. [Command reference](#command-reference)

---

## The sample application

The image contains the **Dice Docker Demo** application from Part 1. It has a React frontend
built with Vite and a Python FastAPI backend served by Uvicorn. Inside the container, FastAPI serves the
compiled React files at `/` and a small JSON API under `/api/*`, all on port **8000**. The
source code and the `Dockerfile` are included in this repository so that the image can be rebuilt
with `docker build -t hammuneer/dice-docker-demo:1.0.0 .`.

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/health` | Health check, returns `{"status": "ok"}` |
| GET | `/api/hello?name=<name>` | Returns a greeting |
| GET | `/api/info` | Returns container details (version, hostname, Python version, platform, time) |
| GET | `/` | Serves the React single-page application |

### Repository structure

```
assignment01_part02/
├── backend/                 # FastAPI application (same as Part 1)
├── frontend/                # React + Vite application (same as Part 1)
├── Dockerfile               # Multi-stage image definition (same as Part 1)
├── .dockerignore
├── host-files/              # Files copied to / from containers with docker cp and docker attach
│   ├── from-host.txt            # copied host -> container
│   ├── main-from-container.py   # copied container -> host
│   ├── exec-note.txt            # created with docker exec, copied container -> host
│   └── attach-commands.sh       # input piped into docker attach
├── logs/                    # Raw output of every command, numbered in the order they were run
└── README.md
```

### Containers used in this part

| Container name | Purpose |
|----------------|---------|
| `dice-app2` → renamed to `dice-web` | The main web application container used for most commands |
| `dice-shell` | An interactive `sh` container used to demonstrate `docker attach` with stdin, stdout and stderr |
| `dice-wait` | A short-lived container that exits with code `3`, used to demonstrate `docker wait` |

> The commands were run in a natural lifecycle order (run → inspect → modify → stop → remove),
> rather than in the order the assignment lists them, so that each command acts on a container
> in the right state. The [command reference](#command-reference) at the end maps every
> required command to its section.

---

## Step 1 – Use the Docker image from Part 1

### 1.1 Pull the image from Docker Hub

**Command:**

```bash
docker pull hammuneer/dice-docker-demo:1.0.0
```

**Description:** Downloads the image from Docker Hub (or confirms that the local copy is already
up to date). This is the same image that was built and pushed in Part 1.

**Output:** ([logs/01-docker-pull.log](logs/01-docker-pull.log))

```
1.0.0: Pulling from hammuneer/dice-docker-demo
Digest: sha256:ca7698b98dcae4515e9248f47f4b84d9c0776c3dc3707e1e4e6c2a7d280b7e4d
Status: Image is up to date for hammuneer/dice-docker-demo:1.0.0
docker.io/hammuneer/dice-docker-demo:1.0.0
```

### 1.2 Verify the image is available locally

**Command:**

```bash
docker image ls hammuneer/dice-docker-demo
```

**Description:** Lists the local images in the `hammuneer/dice-docker-demo` repository.

**Output:** ([logs/01-docker-images.log](logs/01-docker-images.log))

```
IMAGE                              ID             DISK USAGE   CONTENT SIZE   EXTRA
hammuneer/dice-docker-demo:1.0.0   ca7698b98dca        250MB         59.4MB   U
```

---

## Step 2 – Run the Docker Container

### 2.1 `docker run`

**Command:**

```bash
docker run -d --name dice-app2 -p 8080:8000 hammuneer/dice-docker-demo:1.0.0
```

**Description:** Creates and starts a new container from the image.

| Option | Meaning |
|--------|---------|
| `-d` | Detached mode: run the container in the background and print its ID |
| `--name dice-app2` | Give the container a readable name instead of a random one |
| `-p 8080:8000` | Publish container port `8000` on host port `8080` |

**Output:** ([logs/02-docker-run.log](logs/02-docker-run.log))

```
acff99c2d91d64faa015022bd7b92a7782117a2ba049fd4195e70c8b472472bc
```

The long string is the full ID of the new container.

### 2.2 Verify that the application can be accessed

**Commands:**

```bash
curl -s http://localhost:8080/api/health
curl -s 'http://localhost:8080/api/hello?name=Hamza'
curl -s http://localhost:8080/api/info
curl -s http://localhost:8080/ | head -15
```

**Description:** Sends HTTP requests from the host to the published port to confirm that the API
and the React frontend are reachable.

**Output:** ([logs/02-verify-app.log](logs/02-verify-app.log))

```
{"status":"ok"}

{"message":"Hello, Hamza! This response comes from FastAPI inside Docker."}

{"app_version":"1.0.0","hostname":"acff99c2d91d","python_version":"3.12.15","platform":"Linux-6.12.72-linuxkit-x86_64-with-glibc2.41","server_time":"2026-10-26T21:54:58.790119+00:00"}

<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Dice Docker Demo</title>
    <script type="module" crossorigin src="/assets/index-BPRgs4Ta.js"></script>
    <link rel="stylesheet" crossorigin href="/assets/index-BKnbo-Yx.css">
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
```

The `hostname` returned by `/api/info` (`acff99c2d91d`) equals the short container ID, which
proves that the response came from inside this container. The application is also reachable in a
browser at http://localhost:8080.

---

## Step 3 – Docker Container Commands

### 3.1 `docker ps` – list running containers

**Commands:**

```bash
docker ps
docker ps --filter name=dice-app2 --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}'
```

**Description:** `docker ps` lists the containers that are currently running. `--filter` limits
the list to matching containers and `--format` chooses which columns are shown. Adding `-a`
also shows stopped containers (used in later steps).

**Output:** ([logs/03-docker-ps.log](logs/03-docker-ps.log))

```
CONTAINER ID   IMAGE                              COMMAND                  CREATED          STATUS                    PORTS                                         NAMES
acff99c2d91d   hammuneer/dice-docker-demo:1.0.0   "uvicorn main:app --…"   16 seconds ago   Up 15 seconds (healthy)   0.0.0.0:8080->8000/tcp, [::]:8080->8000/tcp   dice-app2

CONTAINER ID   NAMES       STATUS                    PORTS
acff99c2d91d   dice-app2   Up 15 seconds (healthy)   0.0.0.0:8080->8000/tcp, [::]:8080->8000/tcp
```

The status `(healthy)` comes from the `HEALTHCHECK` instruction in the Dockerfile.

### 3.2 `docker logs` – view the logs of a container

**Commands:**

```bash
docker logs dice-app2
docker logs --tail 3 --timestamps dice-app2
```

**Description:** Shows what the container's main process has written to stdout and stderr.
`--tail N` shows only the last N lines and `--timestamps` adds the time of each line. (`-f` would
follow the log live.)

**Output:** ([logs/04-docker-logs.log](logs/04-docker-logs.log))

```
INFO:     Started server process [1]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     172.29.0.1:34037 - "GET /api/health HTTP/1.1" 200 OK
INFO:     172.29.0.1:43046 - "GET /api/hello?name=Hamza HTTP/1.1" 200 OK
INFO:     172.29.0.1:41758 - "GET /api/info HTTP/1.1" 200 OK
INFO:     172.29.0.1:27959 - "GET / HTTP/1.1" 200 OK
INFO:     127.0.0.1:54790 - "GET /api/health HTTP/1.1" 200 OK

2026-10-26T21:54:58.790935167Z INFO:     172.29.0.1:41758 - "GET /api/info HTTP/1.1" 200 OK
2026-10-26T21:54:58.825274337Z INFO:     172.29.0.1:27959 - "GET / HTTP/1.1" 200 OK
2026-10-26T21:54:59.979874942Z INFO:     127.0.0.1:54790 - "GET /api/health HTTP/1.1" 200 OK
```

The log shows Uvicorn starting and every request made in Step 2. Requests from `172.29.0.1`
came from the host through the published port. The request from `127.0.0.1` is the Docker
health check, which runs inside the container.

### 3.3 `docker inspect` – view the details of a container

**Commands:**

```bash
docker inspect dice-app2 > logs/05-docker-inspect-full.json

docker inspect --format 'Name: {{.Name}}
ID: {{.Id}}
Image: {{.Config.Image}}
State: {{.State.Status}} (Running={{.State.Running}}, Pid={{.State.Pid}})
Health: {{.State.Health.Status}}
StartedAt: {{.State.StartedAt}}
Cmd: {{json .Config.Cmd}}
WorkingDir: {{.Config.WorkingDir}}
User: {{.Config.User}}
Env: {{json .Config.Env}}
Networks: {{range $k, $v := .NetworkSettings.Networks}}{{$k}} (IP {{$v.IPAddress}}) {{end}}
Ports: {{json .NetworkSettings.Ports}}
RestartPolicy: {{.HostConfig.RestartPolicy.Name}}
Memory limit: {{.HostConfig.Memory}}
NanoCpus: {{.HostConfig.NanoCpus}}' dice-app2
```

**Description:** `docker inspect` returns the complete low-level configuration and state of a
container as JSON (254 lines here, saved in
[logs/05-docker-inspect-full.json](logs/05-docker-inspect-full.json)). `--format` uses a Go
template to extract only the fields of interest.

**Output (excerpt of the full JSON):**

```json
[
    {
        "Id": "acff99c2d91d64faa015022bd7b92a7782117a2ba049fd4195e70c8b472472bc",
        "Created": "2026-10-26T21:54:54.455362773Z",
        "Path": "uvicorn",
        "Args": [ "main:app", "--host", "0.0.0.0", "--port", "8000" ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 3697,
            "ExitCode": 0,
            "StartedAt": "2026-10-26T21:54:54.536429542Z",
            "Health": { "Status": "healthy", "FailingStreak": 0, ... }
        },
        "Image": "sha256:ca7698b98dcae4515e9248f47f4b84d9c0776c3dc3707e1e4e6c2a7d280b7e4d",
        ...
    }
]
```

**Output of the formatted query:** ([logs/05-docker-inspect.log](logs/05-docker-inspect.log))

```
Name: /dice-app2
ID: acff99c2d91d64faa015022bd7b92a7782117a2ba049fd4195e70c8b472472bc
Image: hammuneer/dice-docker-demo:1.0.0
State: running (Running=true, Pid=3697)
Health: healthy
StartedAt: 2026-10-26T21:54:54.536429542Z
Cmd: ["uvicorn","main:app","--host","0.0.0.0","--port","8000"]
WorkingDir: /app
User: appuser
Env: ["PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","LANG=C.UTF-8","GPG_KEY=7169605F62C751356D054A26A821E680E5FA6305","PYTHON_VERSION=3.12.15","PYTHON_SHA256=c2c4321961fab0fb999d66e0cecf521c2ab3994c7992873ea99e306c1094fd5a","PYTHONDONTWRITEBYTECODE=1","PYTHONUNBUFFERED=1","PIP_NO_CACHE_DIR=1","PIP_ROOT_USER_ACTION=ignore","APP_VERSION=1.0.0"]
Networks: bridge (IP 172.17.0.2)
Ports: {"8000/tcp":[{"HostIp":"0.0.0.0","HostPort":"8080"},{"HostIp":"::","HostPort":"8080"}]}
RestartPolicy: no
Memory limit: 0
NanoCpus: 0
```

The output confirms the settings from the Dockerfile: the `CMD`, the `/app` working directory,
the non-root `appuser` and the environment variables. `Memory limit: 0` and `NanoCpus: 0` mean
that no resource limits are set yet. They are changed later with `docker update`.

> **Issue:** The first attempt used `{{.NetworkSettings.IPAddress}}` and failed with
> `map has no entry for key "IPAddress"`. Docker 29 no longer has this top-level field.
> The IP address is now listed for each network under `.NetworkSettings.Networks`, so the template
> loops over that map instead.

### 3.4 `docker exec` – run a command inside a running container

**Commands:**

```bash
docker exec dice-app2 whoami
docker exec dice-app2 ls -la /app
docker exec dice-app2 python --version
docker exec dice-app2 pip list
docker exec dice-app2 sh -c 'echo Created by docker exec on $(date) > /app/exec-note.txt && cat /app/exec-note.txt'
```

**Description:** Starts an extra process inside a container that is already running, without
restarting it. Here it was used to check the user, list the application files, check the Python
version and installed packages, and create a new file (`exec-note.txt`) inside the container.
(`docker exec -it dice-app2 sh` would open an interactive shell.)

**Output:** ([logs/06-docker-exec.log](logs/06-docker-exec.log))

```
$ docker exec dice-app2 whoami
appuser

$ docker exec dice-app2 ls -la /app
total 20
drwxr-xr-x 1 appuser appuser 4096 Oct 26 21:12 .
drwxr-xr-x 1 root    root    4096 Oct 26 21:54 ..
-rw-r--r-- 1 appuser appuser 1093 Oct 26 20:48 main.py
-rw-r--r-- 1 appuser appuser   43 Oct 26 20:48 requirements.txt
drwxr-xr-x 1 appuser appuser 4096 Oct 26 21:12 static

$ docker exec dice-app2 python --version
Python 3.12.15

$ docker exec dice-app2 pip list
Package           Version
----------------- -------
annotated-types   0.8.0
anyio             4.15.1
click             8.5.0
fastapi           0.115.6
h11               0.16.0
httptools         0.9.0
idna              3.20
pip               26.2.2
pydantic          2.14.1
pydantic_core     2.50.1
python-dotenv     1.2.4
PyYAML            6.0.3
starlette         0.41.3
typing_extensions 4.16.0
typing-inspection 0.4.4
uvicorn           0.34.0
uvloop            0.23.0
watchfiles        1.3.0
websockets        17.3

$ docker exec dice-app2 sh -c 'echo Created by docker exec on $(date) > /app/exec-note.txt && cat /app/exec-note.txt'
Created by docker exec on Mon Oct 26 21:55:11 UTC 2026
```

### 3.5 `docker top` – view the processes running inside a container

**Command:**

```bash
docker top dice-app2
```

**Description:** Lists the processes running inside the container, similar to `ps` on Linux.
The process IDs are shown as the host (the Docker VM) sees them.

**Output:** ([logs/07-docker-top.log](logs/07-docker-top.log))

```
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
1000                3697                3674                5                   21:54               ?                   00:00:01            /usr/local/bin/python3.12 /usr/local/bin/uvicorn main:app --host 0.0.0.0 --port 8000
```

Only one process is running: Uvicorn, as UID `1000` (`appuser`). Its host PID `3697` matches the
`Pid` reported by `docker inspect`.

### 3.6 `docker stats` – view the resource usage of containers

**Command:**

```bash
docker stats --no-stream dice-app2
```

**Description:** Shows live CPU, memory, network and disk I/O usage. `--no-stream` prints a single
snapshot instead of refreshing continuously. Without a container name it shows every running container.

**Output:** ([logs/08-docker-stats.log](logs/08-docker-stats.log))

```
CONTAINER ID   NAME        CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O   PIDS
acff99c2d91d   dice-app2   0.16%     35.25MiB / 7.653GiB   0.45%     3.35kB / 2.86kB   0B / 0B     6
```

With no memory limit set, the limit shown is the total memory of the Docker VM (7.653 GiB).

### 3.7 `docker port` – show the public-facing port mapping

**Commands:**

```bash
docker port dice-app2
docker port dice-app2 8000/tcp
```

**Description:** Shows which host ports are mapped to the container's ports. Passing a
container port shows only the mapping for that port.

**Output:** ([logs/09-docker-port.log](logs/09-docker-port.log))

```
$ docker port dice-app2
8000/tcp -> 0.0.0.0:8080
8000/tcp -> [::]:8080

$ docker port dice-app2 8000/tcp
0.0.0.0:8080
[::]:8080
```

Container port `8000` is published on host port `8080` for IPv4 (`0.0.0.0`) and IPv6 (`[::]`).

### 3.8 `docker cp` – copy files between the container and the host

**Commands:**

```bash
# host -> container
cat host-files/from-host.txt
docker cp host-files/from-host.txt dice-app2:/tmp/from-host.txt
docker exec dice-app2 cat /tmp/from-host.txt

# container -> host
docker cp dice-app2:/app/main.py host-files/main-from-container.py
docker cp dice-app2:/app/exec-note.txt host-files/exec-note.txt
ls -la host-files && cat host-files/exec-note.txt
```

**Description:** Copies files or folders between the host and a container. It works in both
directions and does not need any tools (such as `scp`) inside the container. The syntax is
`docker cp SRC DEST`, where the container side is written `container:path`.

**Output:** ([logs/10-docker-cp.log](logs/10-docker-cp.log))

```
$ cat host-files/from-host.txt
Hello from the host machine!
This file was copied into the container with docker cp.

$ docker cp host-files/from-host.txt dice-app2:/tmp/from-host.txt

$ docker exec dice-app2 cat /tmp/from-host.txt
Hello from the host machine!
This file was copied into the container with docker cp.

$ docker cp dice-app2:/app/main.py host-files/main-from-container.py

$ docker cp dice-app2:/app/exec-note.txt host-files/exec-note.txt

$ ls -la host-files && cat host-files/exec-note.txt
total 24
drwxr-xr-x@ 5 apple  staff   160 Oct 27 02:55 .
drwxr-xr-x@ 9 apple  staff   288 Oct 27 02:54 ..
-rw-r--r--@ 1 apple  staff    55 Oct 27 02:55 exec-note.txt
-rw-r--r--@ 1 apple  staff    85 Oct 27 02:55 from-host.txt
-rw-r--r--@ 1 apple  staff  1093 Oct 27 01:48 main-from-container.py
Created by docker exec on Mon Oct 26 21:55:11 UTC 2026
```

`docker cp` prints nothing when it succeeds. The copied files are committed in
[`host-files/`](host-files).

### 3.9 `docker commit` – create a new image from a container

**Commands:**

```bash
docker commit -a 'Hamza Munir' -m 'Add exec-note.txt and from-host.txt' dice-app2 hammuneer/dice-docker-demo:1.0.0-committed
docker image ls hammuneer/dice-docker-demo
docker history hammuneer/dice-docker-demo:1.0.0-committed | head -4
docker run --rm hammuneer/dice-docker-demo:1.0.0-committed sh -c 'cat /app/exec-note.txt /tmp/from-host.txt'
```

**Description:** Saves the current filesystem changes of a container as a new image layer and
creates a new image from it. `-a` sets the author and `-m` sets a commit message. The container's
changes (`/app/exec-note.txt` from `docker exec` and `/tmp/from-host.txt` from `docker cp`) are
then included in the new image.

**Output:** ([logs/11-docker-commit.log](logs/11-docker-commit.log))

```
$ docker commit -a 'Hamza Munir' -m 'Add exec-note.txt and from-host.txt' dice-app2 hammuneer/dice-docker-demo:1.0.0-committed
sha256:62dd0535f713341ff79522623acf7323833b057aacef03d4512977886033dad4

$ docker image ls hammuneer/dice-docker-demo
IMAGE                                        ID             DISK USAGE   CONTENT SIZE   EXTRA
hammuneer/dice-docker-demo:1.0.0             ca7698b98dca        250MB         59.4MB   U
hammuneer/dice-docker-demo:1.0.0-committed   62dd0535f713        250MB         59.4MB

$ docker history hammuneer/dice-docker-demo:1.0.0-committed | head -4
IMAGE          CREATED                  CREATED BY                                      SIZE      COMMENT
62dd0535f713   Less than a second ago   uvicorn main:app --host 0.0.0.0 --port 8000     20.5kB    Add exec-note.txt and from-host.txt
ca7698b98dca   42 minutes ago           CMD ["uvicorn" "main:app" "--host" "0.0.0.0"…   0B        buildkit.dockerfile.v0
<missing>      42 minutes ago           HEALTHCHECK {Test:[CMD-SHELL python -c "impo…   0B        buildkit.dockerfile.v0

$ docker run --rm hammuneer/dice-docker-demo:1.0.0-committed sh -c 'cat /app/exec-note.txt /tmp/from-host.txt'
Created by docker exec on Mon Oct 26 21:55:11 UTC 2026
Hello from the host machine!
This file was copied into the container with docker cp.
```

`docker history` shows the new 20.5 kB layer, with the commit message, on top of the original
image. A fresh container started from the committed image already contains both files.

### 3.10 `docker attach` – attach to a running container

**Commands:**

```bash
# terminal 1
docker attach --no-stdin --sig-proxy=false dice-app2

# terminal 2 – generate some traffic
curl -s "http://localhost:8080/api/hello?name=Alice"
curl -s "http://localhost:8080/api/hello?name=Bob"
```

**Description:** Connects the terminal to the output of the container's **main process**
(PID 1), so its output appears live. Unlike `docker exec`, it does not start a new
process. `--no-stdin` attaches only stdout and stderr. `--sig-proxy=false` stops Ctrl+C from
being forwarded to the container, so leaving the attach session does not stop the web server.

**Output:** ([logs/12-docker-attach.log](logs/12-docker-attach.log))

```
$ docker attach --no-stdin --sig-proxy=false dice-app2
INFO:     172.29.0.1:61722 - "GET /api/hello?name=Alice HTTP/1.1" 200 OK
INFO:     172.29.0.1:41972 - "GET /api/hello?name=Bob HTTP/1.1" 200 OK
INFO:     127.0.0.1:55010 - "GET /api/health HTTP/1.1" 200 OK
INFO:     127.0.0.1:46248 - "GET /api/health HTTP/1.1" 200 OK
INFO:     127.0.0.1:42422 - "GET /api/health HTTP/1.1" 200 OK
INFO:     127.0.0.1:54112 - "GET /api/health HTTP/1.1" 200 OK
(attach session ended from the host; container keeps running because --sig-proxy=false)

$ docker ps --filter name=dice-app2 --format '{{.Names}}: {{.Status}}'
dice-app2: Up 2 minutes (healthy)
```

The attached terminal showed the Uvicorn access log for the two requests as they happened,
followed by the 30-second health checks. After detaching, the container was still running.

### 3.11 `docker pause` – pause a running container

**Commands:**

```bash
docker pause dice-app2
docker ps --filter name=dice-app2 --format '{{.Names}}: {{.Status}}'
curl -s -m 3 http://localhost:8080/api/health || echo 'Request timed out - the container is paused'
```

**Description:** Freezes every process in the container using the Linux cgroup freezer. The processes
stay in memory but get no CPU time, so the container cannot respond to requests.

**Output:** ([logs/13-docker-pause.log](logs/13-docker-pause.log))

```
$ docker pause dice-app2
dice-app2

$ docker ps --filter name=dice-app2 --format '{{.Names}}: {{.Status}}'
dice-app2: Up 3 minutes (Paused)

$ curl -s -m 3 http://localhost:8080/api/health || echo 'Request timed out - the container is paused'
Request timed out - the container is paused
```

### 3.12 `docker unpause` – unpause a paused container

**Commands:**

```bash
docker unpause dice-app2
docker ps --filter name=dice-app2 --format '{{.Names}}: {{.Status}}'
curl -s -m 3 http://localhost:8080/api/health
```

**Description:** Resumes all processes in a paused container. They continue from exactly where
they stopped. Nothing is restarted.

**Output:** ([logs/14-docker-unpause.log](logs/14-docker-unpause.log))

```
$ docker unpause dice-app2
dice-app2

$ docker ps --filter name=dice-app2 --format '{{.Names}}: {{.Status}}'
dice-app2: Up 3 minutes (unhealthy)

$ curl -s -m 3 http://localhost:8080/api/health
{"status":"ok"}
```

The app responded again immediately. The status briefly showed `(unhealthy)` because a scheduled
health check timed out while the container was frozen. The next health check passed and the status
went back to `(healthy)` (see `docker ps` in [3.20](#320-docker-rm--remove-a-stopped-container)).

### 3.13 `docker rename` – rename a container

**Commands:**

```bash
docker rename dice-app2 dice-web
docker ps --filter id=acff99c2d91d --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}'
```

**Description:** Changes the name of an existing container, whether it is running or not. The
container ID does not change.

**Output:** ([logs/15-docker-rename.log](logs/15-docker-rename.log))

```
$ docker rename dice-app2 dice-web

$ docker ps --filter id=acff99c2d91d --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}'
CONTAINER ID   NAMES      STATUS
acff99c2d91d   dice-web   Up 3 minutes (unhealthy)
```

Same ID (`acff99c2d91d`), new name `dice-web`. All the following commands use the new name.

### 3.14 `docker update` – update a container's resource limits

**Commands:**

```bash
docker update --cpus 0.5 --memory 256m --memory-swap 512m --restart unless-stopped dice-web
docker inspect --format 'Memory={{.HostConfig.Memory}} MemorySwap={{.HostConfig.MemorySwap}} NanoCpus={{.HostConfig.NanoCpus}} Restart={{.HostConfig.RestartPolicy.Name}}' dice-web
docker stats --no-stream dice-web
```

**Description:** Changes a container's resource limits and restart policy while it is running, without
recreating it.

| Option | Meaning |
|--------|---------|
| `--cpus 0.5` | Allow at most half of one CPU core |
| `--memory 256m` | Hard memory limit of 256 MiB |
| `--memory-swap 512m` | Memory + swap limit (must be ≥ `--memory`) |
| `--restart unless-stopped` | Restart automatically unless it was stopped by hand |

**Output:** ([logs/16-docker-update.log](logs/16-docker-update.log))

```
$ docker update --cpus 0.5 --memory 256m --memory-swap 512m --restart unless-stopped dice-web
dice-web

$ docker inspect --format 'Memory=... ' dice-web
Memory=268435456 MemorySwap=536870912 NanoCpus=500000000 Restart=unless-stopped

$ docker stats --no-stream dice-web
CONTAINER ID   NAME       CPU %     MEM USAGE / LIMIT   MEM %     NET I/O           BLOCK I/O    PIDS
acff99c2d91d   dice-web   0.16%     35.23MiB / 256MiB   13.76%    5.46kB / 4.76kB   0B / 4.1kB   6
```

Compared with [3.6](#36-docker-stats--view-the-resource-usage-of-containers), the memory limit
went from `7.653GiB` to `256MiB`, so the same 35 MiB usage is now 13.76% instead of 0.45%.
`docker inspect` shows the new values in bytes (268435456 = 256 × 1024²) and nano-CPUs
(500000000 = 0.5 CPU).

### 3.15 `docker restart` – restart a running container

**Commands:**

```bash
docker restart dice-web
docker ps --filter name=dice-web --format '{{.Names}}: {{.Status}}'
docker inspect --format 'StartedAt={{.State.StartedAt}} RestartCount={{.RestartCount}}' dice-web
docker logs --tail 8 dice-web
docker exec dice-web ls /tmp
```

**Description:** Stops the container (SIGTERM, then SIGKILL after a timeout) and starts it again.
The container keeps its ID, name, settings and writable layer.

**Output:** ([logs/17-docker-restart.log](logs/17-docker-restart.log))

```
$ docker restart dice-web
dice-web

$ docker ps --filter name=dice-web --format '{{.Names}}: {{.Status}}'
dice-web: Up 3 seconds (health: starting)

$ docker inspect --format 'StartedAt={{.State.StartedAt}} RestartCount={{.RestartCount}}' dice-web
StartedAt=2026-10-26T21:58:00.5928008Z RestartCount=0

$ docker logs --tail 8 dice-web
INFO:     Shutting down
INFO:     Waiting for application shutdown.
INFO:     Application shutdown complete.
INFO:     Finished server process [1]
INFO:     Started server process [1]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)

$ docker exec dice-web ls /tmp
from-host.txt
```

- The status changed to `Up 3 seconds` and `StartedAt` is newer than the original start time
  (`21:54:54` → `21:58:00`).
- The logs show a clean shutdown followed by a fresh start.
- `RestartCount` stays `0`. It only counts restarts made automatically by the restart policy,
  not a manual `docker restart`.
- `/tmp/from-host.txt` is still there. A restart keeps the container's filesystem.

### 3.16 `docker stop` – stop a running container

**Commands:**

```bash
docker stop dice-web
docker ps --filter name=dice-web
docker ps -a --filter name=dice-web --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}'
```

**Description:** Stops a running container gracefully. Docker sends SIGTERM to the main
process and, if it has not exited after 10 seconds (default), sends SIGKILL. The stopped
container is not deleted.

**Output:** ([logs/18-docker-stop.log](logs/18-docker-stop.log))

```
$ docker stop dice-web
dice-web

$ docker ps --filter name=dice-web
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$ docker ps -a --filter name=dice-web --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}'
CONTAINER ID   NAMES      STATUS
acff99c2d91d   dice-web   Exited (0) Less than a second ago
```

`docker ps` no longer lists the container. `docker ps -a` shows it is still there, with status
`Exited (0)`: Uvicorn handled SIGTERM and shut down cleanly with exit code 0.

### 3.17 `docker start` – start a stopped container

**Commands:**

```bash
docker start dice-web
docker ps --filter name=dice-web --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}'
curl -s http://localhost:8080/api/health
```

**Description:** Starts an existing stopped container again with the same configuration (ports,
limits, name). `docker run` creates a new container, whereas `docker start` reuses an existing one.

**Output:** ([logs/19-docker-start.log](logs/19-docker-start.log))

```
$ docker start dice-web
dice-web

$ docker ps --filter name=dice-web --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}'
CONTAINER ID   NAMES      STATUS                            PORTS
acff99c2d91d   dice-web   Up 3 seconds (health: starting)   0.0.0.0:8080->8000/tcp, [::]:8080->8000/tcp

$ curl -s http://localhost:8080/api/health
{"status":"ok"}
```

Same container ID, same port mapping, and the application responds again.

### 3.18 `docker attach` – attach local stdin, stdout and stderr

**Commands:**

```bash
docker run -di --name dice-shell hammuneer/dice-docker-demo:1.0.0 sh
docker ps --filter name=dice-shell --format '{{.Names}}: {{.Status}}'
sh host-files/attach-commands.sh | docker attach dice-shell
docker ps -a --filter name=dice-shell --format '{{.Names}}: {{.Status}}'
```

[`host-files/attach-commands.sh`](host-files/attach-commands.sh) writes these lines to stdin,
with short pauses between them:

```sh
echo "stdout: hello from $(hostname) as $(whoami)"
echo "stderr: this line is written to stderr" >&2
python -c "print(\"Sum of 1..10 =\", sum(range(1, 11)))"
exit 7
```

**Description:** The web server in 3.10 does not read any input, so a second container was
started with an interactive shell (`sh`) as its main process. `-d` runs it in the background
and `-i` keeps its stdin open. `docker attach` then connects the host terminal's **stdin, stdout
and stderr** to that shell. Commands typed (here piped) into the host terminal are executed by the
shell inside the container, and its stdout and stderr come back to the host. In an interactive
terminal you would start the container with `-dit` and detach with `Ctrl+P` then `Ctrl+Q`.

**Output:** ([logs/20-docker-attach-stdio.log](logs/20-docker-attach-stdio.log))

```
$ docker run -di --name dice-shell hammuneer/dice-docker-demo:1.0.0 sh
194b22278ad3a84bf329df4e77561ea81c3b31257a466ce2ca8b70b48a6188f8

$ docker ps --filter name=dice-shell --format '{{.Names}}: {{.Status}}'
dice-shell: Up Less than a second (health: starting)

$ sh host-files/attach-commands.sh | docker attach dice-shell
stdout: hello from 194b22278ad3 as appuser
stderr: this line is written to stderr
Sum of 1..10 = 55
[exit code: 7]

$ docker ps -a --filter name=dice-shell --format '{{.Names}}: {{.Status}}'
dice-shell: Exited (7) 1 second ago
```

All three streams worked: the input reached the shell, and both stdout and stderr lines came back
to the host. The `exit 7` command ended the container's main process, so the container stopped
and `docker attach` returned the same exit code, `7`.

> **Issue:** At first the lines were piped in all at once. The shell ran them and exited before
> `docker attach` had connected its output stream, so nothing was printed (the output was only
> visible afterwards with `docker logs dice-shell`). Adding short `sleep` pauses before and after
> the commands, as a human typing would, fixed this.

### 3.19 `docker wait` – wait for a container to exit and show its exit code

**Commands:**

```bash
docker run -d --name dice-wait hammuneer/dice-docker-demo:1.0.0 sh -c 'echo working...; sleep 5; echo done; exit 3'
time docker wait dice-wait
docker logs dice-wait
docker wait dice-shell
```

**Description:** Blocks until one or more containers stop, then prints their exit codes. This is
useful in scripts that must wait for a container (for example a job or a migration) to finish
and then check whether it succeeded.

**Output:** ([logs/21-docker-wait.log](logs/21-docker-wait.log))

```
$ docker run -d --name dice-wait hammuneer/dice-docker-demo:1.0.0 sh -c 'echo working...; sleep 5; echo done; exit 3'
c0dcb171578ef1e9680c62c2654e2151621573a28d78f18b51894a041463009f

$ time docker wait dice-wait
3
  0.03s user 0.02s system 0% cpu 5.169 total

$ docker logs dice-wait
working...
done

$ docker wait dice-shell
7
```

`docker wait dice-wait` blocked for about 5 seconds (the `sleep 5`) and then printed `3`, the
container's exit code. For a container that has already stopped (`dice-shell`), it returns
immediately with the stored exit code `7`.

### 3.20 `docker rm` – remove a stopped container

**Commands:**

```bash
docker ps -a --filter name=dice- --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}'
docker rm dice-web          # fails: the container is still running
docker stop dice-web
docker rm dice-web dice-shell dice-wait
docker ps -a --filter name=dice- --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}'
```

**Description:** Permanently deletes one or more **stopped** containers, including their writable
layer. The image is not affected. Docker refuses to remove a running container unless `-f` is given.

**Output:** ([logs/22-docker-rm.log](logs/22-docker-rm.log))

```
$ docker ps -a --filter name=dice- --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}'
CONTAINER ID   NAMES        STATUS
c0dcb171578e   dice-wait    Exited (3) 5 seconds ago
194b22278ad3   dice-shell   Exited (7) 11 seconds ago
acff99c2d91d   dice-web     Up 51 seconds (healthy)
341ef0c58a75   dice-app     Exited (0) 6 minutes ago

$ docker rm dice-web
Error response from daemon: cannot remove container "dice-web": container is running: stop the container before removing or force remove
[exit code: 1]

$ docker stop dice-web
dice-web

$ docker rm dice-web dice-shell dice-wait
dice-web
dice-shell
dice-wait

$ docker ps -a --filter name=dice- --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}'
CONTAINER ID   NAMES      STATUS
341ef0c58a75   dice-app   Exited (0) 6 minutes ago
```

The first `docker rm` failed because `dice-web` was still running. After `docker stop`, all three
containers from this part were removed. (`dice-app` is the container left over from Part 1.)

---

## Step 4 – Findings and observations

### Container lifecycle

```
            docker run (= create + start)
                     │
                     ▼
   ┌──────────►  RUNNING  ◄──────────┐
   │            │      │  ▲          │
   │  docker    │      │  │ docker   │ docker restart
   │  start     │      │  │ unpause  │
   │            │  docker pause      │
   │            │      ▼  │          │
   │            │     PAUSED         │
   │            │                    │
   │   docker stop / main process exits (docker wait returns here)
   │            ▼
   └─────────  EXITED  ──── docker rm ───►  (removed)
```

### Key learnings

| Topic | Finding |
|-------|---------|
| `run` vs `start` | `docker run` creates a **new** container from an image. `docker start` restarts an **existing** stopped container with its original settings. |
| `stop` vs `pause` | `stop` ends the processes (SIGTERM → SIGKILL) and frees their memory. `pause` only freezes them; they stay in memory and continue exactly where they were. |
| `exec` vs `attach` | `exec` starts a **new** process in the container. `attach` connects to the **existing** main process (PID 1). Exiting an attached shell stops the container. Exiting an `exec` shell does not. |
| `stop` vs `rm` | A stopped container still exists and keeps its filesystem (it shows in `docker ps -a`). `rm` deletes it permanently. |
| `restart` keeps state | Files created with `exec` or `cp` survived `docker restart` and `docker stop`/`start`. They are only lost when the container is removed, unless they are saved with `docker commit`. |
| `commit` | Turns a container's changes into a new image layer. It is handy for debugging, but a Dockerfile is the reproducible way to build images. |
| `update` | CPU and memory limits and the restart policy can be changed on a running container, and the change shows up straight away in `docker stats`. |
| Health checks | The Dockerfile `HEALTHCHECK` shows up in `ps` (`healthy` / `unhealthy`) and in `inspect`. Pausing a container makes its health check time out. |
| Exit codes | `docker wait`, `docker ps -a` (`Exited (N)`) and `docker attach` all report the exit code of the container's main process. |

### Issues encountered

| Issue | Cause | Solution |
|-------|-------|----------|
| `docker inspect` template error `map has no entry for key "IPAddress"` | Docker 29 removed the top-level `NetworkSettings.IPAddress` field | Loop over `.NetworkSettings.Networks` to read the IP address for each network ([3.3](#33-docker-inspect--view-the-details-of-a-container)) |
| Container showed `(unhealthy)` after `unpause` | The health check ran while the container was frozen and timed out | No fix needed: the next health check passed and the status went back to `healthy` |
| Piped `docker attach` printed nothing | The shell finished before attach connected its output stream | Add short pauses in the piped input ([3.18](#318-docker-attach--attach-local-stdin-stdout-and-stderr)) |
| `docker rm` failed on `dice-web` | A running container cannot be removed | Run `docker stop` first (or use `docker rm -f`) |

---

## Step 5 – Push the codebase to GitHub

The codebase (application source, Dockerfile, `host-files/`, `logs/` and this README) was pushed
to a new public repository created for this part:
**https://github.com/hammuneer/dice-assignment1-part2-docker-commands**

```bash
git init -b main
git add .
git commit -m "Assignment 1 Part 2: Docker container commands"
gh repo create hammuneer/dice-assignment1-part2-docker-commands --public \
  --description "DICE Assignment 1 Part 2: Docker container commands" \
  --source . --remote origin
git remote set-url origin git@github.com-personal:hammuneer/dice-assignment1-part2-docker-commands.git
git push -u origin main
```

`gh repo create` creates the public repository on GitHub and adds it as the `origin` remote.
`git remote set-url` switches the remote to the SSH host alias for the personal GitHub account
(the same setup as in Part 1, Step 8.2), and `git push -u` uploads the `main` branch and sets it
to track `origin/main`.

**Output:** ([logs/23-git-commit.log](logs/23-git-commit.log), [logs/24-gh-repo-create.log](logs/24-gh-repo-create.log), [logs/25-git-push.log](logs/25-git-push.log))

```
$ gh repo create hammuneer/dice-assignment1-part2-docker-commands --public ... --source . --remote origin
https://github.com/hammuneer/dice-assignment1-part2-docker-commands

$ git push -u origin main
To github.com-personal:hammuneer/dice-assignment1-part2-docker-commands.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

### Verify the codebase on GitHub

**Commands:**

```bash
gh repo view hammuneer/dice-assignment1-part2-docker-commands --json name,visibility,url,defaultBranchRef,description
gh api repos/hammuneer/dice-assignment1-part2-docker-commands/contents --jq '.[].name'
```

**Description:** Asks the GitHub API for the repository's details and for the list of files on
the `main` branch, to confirm that the push worked and the repository is public.

**Output:** ([logs/26-gh-repo-view.log](logs/26-gh-repo-view.log))

```
{"defaultBranchRef":{"name":"main"},"description":"DICE Assignment 1 Part 2: Docker container commands","name":"dice-assignment1-part2-docker-commands","url":"https://github.com/hammuneer/dice-assignment1-part2-docker-commands","visibility":"PUBLIC"}

.dockerignore
.gitignore
Dockerfile
README.md
backend
frontend
host-files
logs
```

---

## Command reference

The assignment's list of commands, in the order it gives them, mapped to the section where each
one is documented:

| # | Command | Purpose | Section |
|---|---------|---------|---------|
| 1 | `docker ps` | List running containers | [3.1](#31-docker-ps--list-running-containers) |
| 2 | `docker stop` | Stop a running container | [3.16](#316-docker-stop--stop-a-running-container) |
| 3 | `docker rm` | Remove a stopped container | [3.20](#320-docker-rm--remove-a-stopped-container) |
| 4 | `docker logs` | View the logs of a container | [3.2](#32-docker-logs--view-the-logs-of-a-container) |
| 5 | `docker inspect` | View the details of a container | [3.3](#33-docker-inspect--view-the-details-of-a-container) |
| 6 | `docker exec` | Execute a command inside a running container | [3.4](#34-docker-exec--run-a-command-inside-a-running-container) |
| 7 | `docker attach` | Attach to a running container | [3.10](#310-docker-attach--attach-to-a-running-container) |
| 8 | `docker commit` | Create a new image from a container | [3.9](#39-docker-commit--create-a-new-image-from-a-container) |
| 9 | `docker cp` | Copy files between the container and the host | [3.8](#38-docker-cp--copy-files-between-the-container-and-the-host) |
| 10 | `docker stats` | View the resource usage of containers | [3.6](#36-docker-stats--view-the-resource-usage-of-containers) |
| 11 | `docker top` | View the running processes inside a container | [3.5](#35-docker-top--view-the-processes-running-inside-a-container) |
| 12 | `docker start` | Start a stopped container | [3.17](#317-docker-start--start-a-stopped-container) |
| 13 | `docker pause` | Pause a running container | [3.11](#311-docker-pause--pause-a-running-container) |
| 14 | `docker unpause` | Unpause a paused container | [3.12](#312-docker-unpause--unpause-a-paused-container) |
| 15 | `docker rename` | Rename a container | [3.13](#313-docker-rename--rename-a-container) |
| 16 | `docker wait` | Wait for a container to exit and show its exit code | [3.19](#319-docker-wait--wait-for-a-container-to-exit-and-show-its-exit-code) |
| 17 | `docker attach` | Attach local stdin, stdout and stderr to a running container | [3.18](#318-docker-attach--attach-local-stdin-stdout-and-stderr) |
| 18 | `docker port` | Show the public-facing port of a container | [3.7](#37-docker-port--show-the-public-facing-port-mapping) |
| 19 | `docker update` | Update a container's resource limits | [3.14](#314-docker-update--update-a-containers-resource-limits) |
| 20 | `docker restart` | Restart a running container | [3.15](#315-docker-restart--restart-a-running-container) |

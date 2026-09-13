# Debugging

List the running containers:

```
docker ps
```

Find the addon container, then tail its logs. The name is `addon_local_sure` only when the addon is built locally; installed from this repository it is `addon_<repository-hash>_sure`, so let `docker ps` tell you:

```
docker ps --filter name=sure --format '{{.Names}}'
docker logs <name from above>
```

The addon runs two processes, so check that both appear in the logs: Puma (`Listening on http://0.0.0.0:3000`) and Sidekiq (`Booted Rails ... in "production" environment`). If Sidekiq exits — usually an unreachable `redis_url` — the addon stops as well.

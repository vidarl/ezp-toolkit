# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal support/debugging toolkit for running, upgrading and profiling eZ Publish Platform, eZ Platform and Ibexa DXP in Docker. It is **not an application** — there is no build, no dependency manifest, no test suite, no linter. Everything is Bash scripts, Docker Compose overlay files, Dockerfiles, SQL and Markdown runbooks.

Consequence: changes are validated by running the scripts against a real Ibexa installation, not by a CI command. Do not invent build/test commands.

## The central convention: `external/ezp-toolkit`

This repo is never used standalone. It is cloned **into a host Ibexa/eZ project** as `external/ezp-toolkit`:

```bash
mkdir external && cd external && git clone git@github.com:vidarl/ezp-toolkit.git && cd ..
```

Every path inside scripts, comments and docs is written from the perspective of the host project root (`external/ezp-toolkit/ezplatform/xdebug.yml`, `./external/ezp-toolkit/database/upgrade_db.sh local`). Keep new files consistent with that — a path relative to this repo's own root is almost always wrong in user-facing docs.

`ibexa/install_dxp.sh` performs this clone automatically (using the SSH remote when `whoami` is `vl`, HTTPS otherwise).

## Compose overlay model (`ezplatform/`)

The host project ships its own stack in `doc/docker/*.yml` (from `ibexa/docker`). Files in `ezplatform/` are **overlays** appended to `COMPOSE_FILE` in the host `.env`, colon-separated:

```
COMPOSE_FILE=doc/docker/base-dev.yml:doc/docker/solr.yml:external/ezp-toolkit/ezplatform/solr8.yml:external/ezp-toolkit/ezplatform/solr-dev.yml
```

Rules that follow from this:

- **Order matters.** Later files override earlier ones. Several overlays state their required predecessor in a header comment (`solr8.yml` needs `doc/docker/solr.yml` first; session overlays must come after `base-*.yml` but before `selenium.yml`). Preserve and update those header comments — they are the only documentation for most overlays.
- **`${COMPOSE_DIR}/../../` is the host project root.** Compose resolves relative volume paths against the compose file's directory (`doc/docker/`), so bind mounts into the project are written as `${COMPOSE_DIR}/../../vendor/...`. Copy this pattern rather than using plain relative paths.
- Overlays only redeclare the services they touch (usually `app`, `web`, `varnish`, `solr`, `redis`), relying on merge with the base file.
- Some overlays carry vendor-path variants for different DXP majors (e.g. `varnish.yml` mounts both the 3.3 `ezsystems/ezplatform-http-cache` and the 4.5 `ibexa/http-cache` VCL path); the wrong one is expected to be commented out by the user.

`docker-ezpublishplatform/` is the older, self-contained generation for eZ Publish Platform 5.4 — it defines the *whole* stack (`Docker-composer.yml`, `dockerfiles/`, `.env-dist`) rather than overlaying a vendor one. Don't mix the two directories.

## Version → PHP image mapping

`ibexa/install_dxp.sh` and `ibexa/start_a_container.sh` both contain a chain of `if [[ "$version" =~ ^4.3 ]]` blocks setting `PHP_IMAGE`. **They are duplicated and drift.** When adding support for a new DXP version, update both, and note the registry moved from `ezsystems/php:*` (≤4.5) to `ghcr.io/ibexa/docker/php:*` (3.3 and ≥4.6).

`install_dxp.sh` also branches on `DEV_INSTALL`, set only for `~5.0.x-dev`: dev installs start from `ibexa/website-skeleton`, add the `updates.ibexa.co` composer repository explicitly, and run `recipes:install`/`post-update-cmd`; stable installs use `ibexa/${flavour}-skeleton` with `--no-install --no-scripts`.

Usage:

```bash
./ezp-toolkit/ibexa/install_dxp.sh <flavour> <project_name> <target_dir> <version>
# flavour: content | experience | commerce (commerce largely untested)
./ezp-toolkit/ibexa/install_dxp.sh experience projectvtest vtest 3.3.21
./ezp-toolkit/ibexa/install_dxp.sh experience exp50dev exp50dev '~5.0.x-dev'
```

The script runs `composer` in a throwaway container named `install_dxp` before the stack exists, mounting `$HOME/www-data` as the container's home. It hard-requires `$HOME/www-data/.composer/auth.json` with credentials for `updates.ibexa.co` (`check_homedir_skeleton`). It also `git init`s the target and commits at each milestone — that commit sequence is deliberate, so a user can inspect what each install step changed.

## Where scripts run

Scripts split into two groups; getting this wrong is the usual failure mode.

- **Inside the `app` container** (`docker compose exec --user www-data app bash`): `database/*.sh` (they talk to host `db` with user `ezp`), `bin/createPasswordHash.php`.
- **On the host**, driving Docker from outside: `ibexa/*.sh`, `xdebug/prepare_container_for_xdebug.sh`, `ezplatform/start_redis-cluster.sh`. `xdebug/internal_install_xdebug.sh` is the in-container half, invoked by `prepare_container_for_xdebug.sh` — never run it directly.

`prepare_container_for_xdebug.sh` must be re-run after every host reboot, because it resolves the Windows/WSL host IP that xdebug dials back to. Flags: no args = enable/install, `--disable`, `--force-reinstall`.

## REST scripts (`rest/`)

Session-based scripts are **sourced**, not executed, because they export shell state:

```bash
export BASE_URL=http://localhost:8080
source ./login.sh          # exports SESSION_NAME, SESSION_VALUE, CSRF_TOKEN
./load_content.sh 52
```

`login_jwt.sh` is the JWT variant, exporting `JWT_TOKEN`. Every script guards on `BASE_URL` and builds `API_URL=${BASE_URL}/api/ibexa/v2`; new scripts should follow the same guard-and-export shape and depend on `jq`. Credentials are hardcoded `admin`/`publish` (throwaway local installs).

## Documentation shape

`README.md`, `database/README.md`, `upgrade/upgrade_files_3333oss_to_46.md` and `tuning.md` are runbooks: copy-pasteable command sequences with inline caveats, ordered oldest-platform-first. `upgrade/*.md` documents a stepwise upgrade path (3.3.x → latest 3.3 → 4.x) where each intermediate version matters — don't collapse the steps. Overlay files document themselves in header comments; that is the expected place for setup instructions on a new overlay, not a separate Markdown file.

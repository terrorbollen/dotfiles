# dotfiles
My dotfiles

## TODO: CLI tools to add

### High priority
- `gh` — create PRs, review issues, check CI status without leaving terminal
- `yq` — edit/query k8s manifests, helm values, any YAML in scripts
- `kubectx` / `kubens` — switch clusters/namespaces in one keystroke instead of `kubectl config use-context <long-name>`
- `stern` — tail logs from all pods matching a label at once (e.g. all pods of a deployment)
- `zoxide` — jump to any recent dir with 2-3 chars instead of full path

### Medium
- `ruff` — replaces black+flake8+isort, 10-100x faster, use in pre-commit + editor
- `fd` — better `find`, saner syntax, used in fzf integrations
- `bat` — `cat` with syntax highlighting + line numbers, also used by fzf previews
- `delta` — already installed, wire into git config if not done

### Lower
- `ipython` — better Python REPL for quick data exploration/debugging
- `pgcli` — postgres REPL with autocomplete for table/column names
- `mycli` — same but MySQL
- `usql` — one CLI for all DBs, useful when switching between postgres/sqlite/etc
- `tsx` — run `.ts` files directly like `node script.js` but for TypeScript

# workflows (actionlint, incl. shellcheck of 'run:' scripts), then scripts (shellcheck: actionlint doesn't check them).
# Needs actionlint, see Confluence "Basic setup"
lint:
	@actionlint && shellcheck scripts/*.sh

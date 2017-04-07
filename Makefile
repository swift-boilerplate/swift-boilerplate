dependencies: submodules
bootstrap: dependencies
	brew update || brew update
	brew unlink swiftlint || true
	brew install swiftlint
	brew link --overwrite swiftlint
submodules:
	git submodule sync --recursive || true
	git submodule update --init --recursive || true
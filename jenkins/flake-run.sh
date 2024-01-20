#!/bin/bash -l

# Workaround: Seems like Jenkins does not set the POSIX standard environment
# variable 'USER', but they do set 'user'.
if [[ -n "$user" && -z "$USER" ]]; then
	export USER="$user"
fi

# Since USER was not set when bash invoked our rc file, we have to manually
# setup the environment for Nix here. Annoying.
source $HOME/.nix-profile/etc/profile.d/nix.sh

# Pass the arguments to bash running in a nix devShell.
nix develop -v --command bash $@

#!/usr/bin/env bash
set -e

script_path=$(readlink -f $(dirname "$0"))
source $script_path/../../util.sh

loginfo "=== start test _default_ ==="


loginfo "=== test region special $CLOUDIDE_PROVIDER_REGION ==="
if [ "$CLOUDIDE_PROVIDER_REGION" = "cn" ] ;then
    assert_regex "registry.npmmirror.com"  "cat ~/.npmrc"
else
    assert 'a0deploydeamon 进程端口正常' -- curl localhost:19002/version
fi


loginfo "=== test file system ==="
assert touch /cloudide/workspace/.abc
assert touch /tmp/.abc
assert touch /cloudide/component/current/.abc
assert touch /cloudide/component/deamon/.abc
assert touch /cloudide/component/download/.abc
assert touch /cloudide/meta/.abc
assert touch /cloudide/compliance/.abc
assert touch /cloudide/socket/.abc
assert touch /cloudide/component/log/.abc
assert test -e /cloudide-cache/vscode-extensions
assert_regex_invert '^$' ls /cloudide-cache/vscode-extensions
assert_regex_invert '^$' ls /cloudide-cache/nix
# mkdir -p /tmp/empty
# assert_regex_invert '^$' ls /tmp/empty
assert test -e /home/cloudide-origin/.zshrc
assert test -e /etc/command-not-found.sh
assert test -e /etc/cloudide_profile
assert test -e /etc/shellIntegration-bash.sh
assert test -e /etc/shellIntegration-rc.zsh
assert ! touch /.abc
assert_regex_invert '^$' ls /nix/store
assert touch /nix/store/.abc
assert_regex_invert '^$' ls /nix/store/.abc
# assert_regex_invert '^$' ls /nix-store-upper
assert test -e '/usr/lib/librtldloader.so'
assert test -e "$HOME/.local/state/nix/builtin/lib/libz.so"
assert test -e "$HOME/.local/state/nix/builtin/lib/libssl.so"
assert test -e "$HOME/.local/state/nix/builtin/lib/libstdc++.so"


loginfo "=== test environment variables ==="
assert '[ "$CLOUDIDE_APISERVER_BASE_URL" = "https://bytesec.byteintlapi.com" ] || [ "$CLOUDIDE_APISERVER_BASE_URL" = "https://api-sg-central.marscode.com" ] || [ "$CLOUDIDE_APISERVER_BASE_URL" = "https://api-us-east.marscode.com" ] || [ "$CLOUDIDE_APISERVER_BASE_URL" = "https://bytesec.bytedance.com" ] || [ "$CLOUDIDE_APISERVER_BASE_URL" = "https://api.marscode.cn" ]'
assert '[ "$CLOUDIDE_APISERVER_USE_GATEWAY" = "true" ]'
assert '! [ -z "$CLOUDIDE_WORKSPACE_ID" ]'
assert '! [ -z "$CLOUDIDE_NAME" ]'
assert '[ "$CLOUDIDE_WORKSPACEPATH" = "/cloudide/workspace" ]'
assert '! [ -z "$CLOUDIDE_OPENEDPATH" ]'
assert '! [ -z "$AIRPOD_WS_TOKEN" ]'
assert '! [ -z "$AIRPOD_WSID" ]'
assert '! [ -z "$AIRPOD_WS_REGION" ]'
assert '! [ -z "$AIRPOD_WS_DC" ]'
assert '[ "$CLOUDIDE_PROVIDER_REGION" = "cn" ] || [ "$CLOUDIDE_PROVIDER_REGION" = "sg" ] || [ "$CLOUDIDE_PROVIDER_REGION" = "us" ]'
assert '[ "$CLOUDIDE_TENANT_NAME" = "public" ] '
assert '[ "$CLOUDIDE_IDE_SERVER_TYPE" = "icube_a0" ] '
assert '[ "$CLOUDIDE_CONTROL_PLANE" = "boe" ] || [ "$CLOUDIDE_CONTROL_PLANE" = "boei18n" ] || [ "$CLOUDIDE_CONTROL_PLANE" = "i18n" ] || [ "$CLOUDIDE_CONTROL_PLANE" = "sg" ] || [ "$CLOUDIDE_CONTROL_PLANE" = "cn" ]'
assert '[ "$CLOUDIDE_TENANT_ID" = "1dknw951n5p5vn" ] || [ "$CLOUDIDE_TENANT_ID" = "82g9meypogge2g" ]'
assert '! [ -z "$CLOUDIDE_PROJECT_ID" ]'
assert '[ "$CLOUDIDE_TEMPLATE" = "nix" ]'

assert_regex '.nix-profile/lib/pkgconfig' 'echo $PKG_CONFIG_PATH'
assert_regex '.local/state/nix/builtin/lib/pkgconfig' 'echo $PKG_CONFIG_PATH'
assert_regex '.nix-profile/share/pkgconfig' 'echo $PKG_CONFIG_PATH'
assert_regex '.local/state/nix/builtin/share/pkgconfig' 'echo $PKG_CONFIG_PATH'
assert_regex '.local/state/nix/builtin' 'echo $OPENSSL_ROOT_DIR'
assert_regex '.nix-profile/include' 'echo $CPATH'
assert_regex '.local/state/nix/builtin/include' 'echo $CPATH'
assert_regex '.local/state/nix/builtin/include' 'echo $CPATH'
assert_regex '.local/state/nix/builtin/include' 'echo $CPLUS_INCLUDE_PATH'
assert_regex '.local/state/nix/builtin/include' 'echo $CPLUS_INCLUDE_PATH'
assert_regex '.npm' 'echo $npm_config_prefix'
assert_regex '.local/state/nix/profiles/profile/lib/mariadb' 'echo $CLOUDIDE_LD_LIBRARY_PATH'
assert_regex '.local/state/nix/profiles/profile/lib64' 'echo $CLOUDIDE_LD_LIBRARY_PATH'
assert_regex '.local/state/nix/profiles/profile/lib' 'echo $CLOUDIDE_LD_LIBRARY_PATH'
assert_regex '.local/state/nix/builtin/lib64' 'echo $CLOUDIDE_LD_LIBRARY_PATH'
assert_regex '.local/state/nix/builtin/lib' 'echo $CLOUDIDE_LD_LIBRARY_PATH'
assert_regex '/usr/lib/librtldloader.so' 'echo $LD_AUDIT'
assert_regex '.npm/bin' 'echo $PATH'


loginfo "=== test component process ==="
assert 'workspaceagent 进程端口正常' -- curl localhost:29003
assert 'icube 进程端口正常' --  curl localhost:29501/version


loginfo "=== test command ==="
assert which bash
assert which sh
assert which wget
assert which curl
assert which git
assert which sudo
assert which netstat
assert which nc
assert which zsh
assert which socat
assert which man
assert which tmux
assert which rsync
assert which sshpass
assert which unzip
assert which locale
assert which ip
assert which ping
assert which less
assert which vim
assert which nc
assert which xz
assert which fzy
assert which jq
assert which nix
assert which nix-build
assert which nix-channel
assert which nix-channel-index
assert which nix-collect-garbage
assert which nix-copy-closure
assert which nix-daemon
assert which nix-env
assert which nix-hash
assert which nix-index
assert which nix-instantiate
assert which nix-locate
assert which nix-prefetch-url
assert which nix-shell
assert which nix-store
assert which rippkgs
assert which rippkgs-index
assert which python python3 python3.12 pip node gcc openssl gdb make pkg-config gettext


loginfo "=== test nix install ==="
assert nix-env -iA nixpkgs.bind
assert dig

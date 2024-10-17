#!/usr/bin/env bash
set -e


script_path=$(readlink -f $(dirname "$0"))
source $script_path/../../util.sh


clear(){
    loginfo "will clear test data"
    rm -rf /tmp/test/rust
    rm -rf ~/.rustup && mkdir -p ~/.rustup
}
trap '[ "$?" -eq 0 ] && clear || true' EXIT
clear


if [ "$CLOUDIDE_PROVIDER_REGION" = "cn" ] ;then
    assert_regex "rsproxy-sparse" 'cat ~/.cargo/config'
    assert_regex "rsproxy.cn" 'cat ~/.cargo/config'
else
    loginfo "no region special test, skip"
fi


loginfo "=== start test basic env ==="
assert which rustc cargo rust-analyzer rustc rustdoc rust-gdb rust-gdbgui rust-lldb rustup
assert_regex '.cargo/bin' 'echo $PATH'
assert_regex "'git-fetch-with-cli = true'" 'cat ~/.cargo/config'
assert_regex 'rust-analyzer.debug.engine.*vadimcn.vscode-lldb' 'cat /cloudide/workspace/.cloudide/data/Machine/settings.json'
assert_regex 'rust-analyzer.server.path.*/home/cloudide/.local/state/nix/builtin/bin/rust-analyzer' 'cat /cloudide/workspace/.cloudide/data/Machine/settings.json'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/swellaby.vscode-rust-test-adapter-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/hbenl.test-adapter-converter-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/hbenl.vscode-test-explorer-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/rust-lang.rust-analyzer-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/serayuzgur.crates-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/bungcip.better-toml-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/vadimcn.vscode-lldb-*) && [ ${#arr[@]} -ne 0 ]'


loginfo "=== start test cargo rust hello project ==="
mkdir -p /tmp/test/rust
cd /tmp/test/rust
assert cargo new hello
cd hello
assert_regex "'Hello, world!'" cargo run
assert cargo build --release
assert_regex "'Hello, world!'" ./target/release/hello


loginfo "=== start test rustup"
assert rustup install 1.80.1
assert_regex '1.80.1' rustc -V

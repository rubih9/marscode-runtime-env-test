#!/usr/bin/env bash
set -e

script_path=$(readlink -f $(dirname "$0"))

source $script_path/util.sh

loginfo "=== start run.sh ==="

if ! test -f ~/.local/state/nix/.installed-runtime-packs ;then
    loginfo "this is not nix env, skip test"
    exit 0
fi

runtime_packs_name_arr=($(cat ~/.local/state/nix/.installed-runtime-packs))
for runtime_pack_name in "${runtime_packs_name_arr[@]}"
do
    lang=$(echo $runtime_pack_name | cut -d'@' -f1)
    loginfo "=== will test $lang ==="
    bash -e $script_path/test/$lang/run.sh
done

#!/usr/bin/env bash
set -e


script_path=$(readlink -f $(dirname "$0"))
source $script_path/../../util.sh


clear(){
    loginfo "will clear test data"
    rm -rf ~/.moon && mkdir -p ~/.moon
}
trap '[ "$?" -eq 0 ] && clear || true' EXIT
clear


loginfo "=== start test basic env ==="
assert which moon  moonc  mooncake  moon_cove_report  moondoc  moonfmt  mooninfo  moonrun
assert_regex $HOME/.moon/bin 'echo $PATH' 
assert 'arr=(/cloudide/workspace/.cloudide/extensions/moonbit.moonbit-lang-*) && [ ${#arr[@]} -ne 0 ]'


loginfo "=== start test hello project ==="
cd $script_path/../../data/moonbit/hello
assert_regex Hello 'source ~/.bashrc && sleep 10 && moon run main'


loginfo "=== start test moon update ==="
# 无语： moonbit 没有 -y 参数，用 yes 命令也解决不了。。。
# assert 'bash -c "yes | moon upgrade"'
if [ "$CLOUDIDE_PROVIDER_REGION" = "cn" ] ;then
    assert 'curl -fsSL https://cli.moonbitlang.cn/install/unix.sh | bash'
else
    assert 'curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash'
fi
assert_regex $HOME/.moon/bin/moon which moon
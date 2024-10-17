#!/usr/bin/env bash
set -e


script_path=$(readlink -f $(dirname "$0"))
source $script_path/../../util.sh


clear(){
    loginfo "will clear test data"
    rm -rf $script_path/../../data/nodejs/koa/app
    rm -rf $script_path/../../data/nodejs/koa/node_modules
    cd $script_path/../../data/nodejs/koa
    npm remove sass bcrypt sqlite3 krb5
    rm -rf ~/.nvm/alias ~/.nvm/versions
    # rm -rf ~/.nvm/.cache
    rm -rf /home/cloudide/.local/share/fnm /cloudide/workspace/.tmp
}
trap '[ "$?" -eq 0 ] && clear || true' EXIT
clear


if [ "$CLOUDIDE_PROVIDER_REGION" = "cn" ] ;then
    assert_regex "npmmirror.com" 'echo $FNM_NODE_DIST_MIRROR'
    assert_regex "npmmirror.com" 'echo $NVM_NODEJS_ORG_MIRROR'
else
    loginfo "no region special test, skip"
fi


loginfo "=== start test basic env ==="
assert ls -al ~/.npm/lib
assert_regex 'yarn' cat ~/.nvm/default-packages
assert_regex 'pnpm' cat ~/.nvm/default-packages
assert_regex 'node_modules/.bin' 'echo $PATH'
assert_regex ${PNPM_HOME:-fadsfsdfdasf} 'echo $PATH'
assert_regex .npm/bin 'echo $PATH'
assert ! test -z $FNM_NODE_DIST_MIRROR
assert_regex $HOME/.nvm 'echo $NVM_DIR'
assert_regex $HOME/.local/share/pnpm 'echo $PNPM_HOME'
assert_regex $HOME/.npm 'echo $npm_config_prefix'
assert "bash -c 'source ~/.bashrc && type fnm'"
assert which node
assert which npm
assert which npx
assert which nvm.sh
assert "bash -c 'source ~/.bashrc && type nvm'"
assert which pnpm
assert which pnpx
assert which yarn
assert which yarnpkg
assert 'arr=(/cloudide/workspace/.cloudide/extensions/dbaeumer.vscode-eslint-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/vue.volar-*) && [ ${#arr[@]} -ne 0 ]'


loginfo "=== start test package manager ==="
cd $script_path/../../data/nodejs/koa

if [ "$CLOUDIDE_PROVIDER_REGION" = "cn" ] ;then
    export ELECTRON_MIRROR=http://npmmirror.com/mirrors/electron/
fi

assert pnpm --version
assert pnpm install
assert_http http://localhost:3000 200 pnpm run start
assert pnpm i -g @electron-forge/cli
assert which electron-forge
assert 'electron-forge init --template=webpack app'
assert pnpm add tree-sitter tree-sitter-javascript
assert pnpm rebuild
assert pnpm remove tree-sitter tree-sitter-javascript
assert pnpm rebuild
rm -rf node_modules
rm -rf $script_path/../../data/nodejs/koa/app

assert npm install
assert_http http://localhost:3000 200 npm run start
assert npm i -g @electron-forge/cli
assert which electron-forge
assert 'electron-forge init --template=webpack app'
assert npm install tree-sitter tree-sitter-javascript
assert npm rebuild
assert npm remove tree-sitter tree-sitter-javascript
assert npm rebuild
rm -rf node_modules
rm -rf $script_path/../../data/nodejs/koa/app

assert yarn install
assert_http http://localhost:3000 200 yarn run start
assert yarn global add @electron-forge/cli
assert which electron-forge
assert 'electron-forge init --template=webpack app'
assert yarn add tree-sitter tree-sitter-javascript
assert yarn install --force
assert yarn remove tree-sitter tree-sitter-javascript
assert yarn install --force
rm -rf node_modules
rm -rf $script_path/../../data/nodejs/koa/app


loginfo "=== start test nvm ==="
assert "bash -c 'source ~/.bashrc && nvm install 16'"
assert_regex 16 "bash -c 'source ~/.bashrc && node -v'"
assert_regex "$HOME/.nvm/versions/node/"  "bash -c 'source ~/.bashrc && which npm'"
assert_regex "$HOME/.nvm/versions/node/"  "bash -c 'source ~/.bashrc && which pnpm'"
assert_regex "$HOME/.nvm/versions/node/"  "bash -c 'source ~/.bashrc && which yarn'"
rm -rf ~/.nvm/alias ~/.nvm/versions
# rm -rf ~/.nvm/.cache


loginfo "=== start test fnm ==="
assert "bash -c 'source ~/.bashrc && fnm install 18'"
assert_regex 18 "bash -c 'source ~/.bashrc && node -v'"
assert_regex 'fnm_multishells/.*/bin/npm' "bash -c 'source ~/.bashrc && which npm'"
assert_regex 'fnm_multishells/.*/bin/pnpm' "bash -c 'source ~/.bashrc && which pnpm'"
assert_regex 'fnm_multishells/.*/bin/yarn' "bash -c 'source ~/.bashrc && which yarn'"
rm -rf /home/cloudide/.local/share/fnm /cloudide/workspace/.tmp


loginfo "=== start test node gyp ==="
cd $script_path/../../data/nodejs/koa
assert 'nix-env -iA nixpkgs.libkrb5 && pip install setuptools && CC=$(which gcc) npm i krb5'
assert npm i sass bcrypt sqlite3
npm remove sass bcrypt sqlite3 krb5

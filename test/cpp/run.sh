#!/usr/bin/env bash
set -e


script_path=$(readlink -f $(dirname "$0"))
source $script_path/../../util.sh


clear(){
    loginfo "will clear test data"
    rm -rf $script_path/../../data/cpp/hello/c-main
    rm -rf $script_path/../../data/cpp/hello/cpp-main
    rm -rf $script_path/../../data/cpp/cmake/build
    rm -rf /tmp/test/cpp
}
trap '[ "$?" -eq 0 ] && clear || true' EXIT
clear


loginfo "=== start test basic env ==="
assert which clang-apply-replacements clangd clang-format clang-linker-wrapper clang-offload-packager clang-refactor clang-repl clang-change-namespace clang-doc clang-include-cleaner clang-move clang-pseudo clang-rename clang-scan-deps clang-check clang-extdef-mapping clang-include-fixer clang-offload-bundler clang-query clang-reorder-fields clang-tidy
assert which cmake cpack ctest
assert which autoconf  autoheader  autom4te  autoreconf  autoscan  autoupdate  ifnames
assert which aclocal automake
assert which m4
assert which libtool  libtoolize
assert_regex $HOME/.nix-profile/share/aclocal 'echo $ACLOCAL_PATH' 
assert_regex $HOME/.local/state/nix/builtin/share/aclocal 'echo $ACLOCAL_PATH'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/jeff-hykin.better-cpp-syntax-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/hbenl.test-adapter-converter-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/hbenl.vscode-test-explorer-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/rust-lang.rust-analyzer-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/serayuzgur.crates-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/bungcip.better-toml-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/vadimcn.vscode-lldb-*) && [ ${#arr[@]} -ne 0 ]'


loginfo "=== start test hello project"
cd $script_path/../../data/cpp/hello
assert g++ main.cpp -o cpp-main
assert_regex "Hello" ./cpp-main
assert gcc main.c -o c-main
assert_regex "Hello" ./c-main


loginfo "=== start test cmake project"
cd $script_path/../../data/cpp/cmake
assert cmake -S./ -B./build
assert cmake --build ./build
assert_regex "Hello" ./build/main


loginfo "=== start test compile dropbear"
mkdir -p /tmp/test/cpp
cd /tmp/test/cpp
git clone https://github.com/mkj/dropbear.git
cd dropbear
git checkout DROPBEAR_2022.83
assert nix-env -iA nixpkgs.zlib nixpkgs.libxcrypt
assert ./configure --prefix=$HOME/.local
assert 'source ~/.bashrc && make PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp"'
assert make install
assert ~/.local/sbin/dropbear -h


loginfo "=== start test compile leveldb"
mkdir -p /tmp/test/cpp
cd /tmp/test/cpp
git clone https://github.com/google/leveldb
cd leveldb
git submodule update --init --recursive
mkdir -p build && cd build
assert cmake -DCMAKE_BUILD_TYPE=Release ..
assert cmake --build .
assert make test


loginfo "=== start test compile curl with nghttp2"
mkdir -p /tmp/test/cpp
cd /tmp/test/cpp
git clone https://github.com/nghttp2/nghttp2
cd nghttp2
git checkout d97bc7d8745ded136efa6e9e747f2310406893dd
git submodule update --init
assert autoreconf -i
assert automake
assert autoconf
assert ./configure --prefix=$HOME/.local
assert make
assert make install
assert_regex libnghttp2.a ls -al ~/.local/lib 
assert_regex libnghttp2.so ls -al ~/.local/lib 

cd ../
git clone https://github.com/curl/curl
cd curl
git checkout ba235ab269080dc66e35835c829f7ac4290dbc1d
assert autoreconf -fi
assert nix-env -iA nixpkgs.libpsl
assert ./configure --prefix=$HOME/.local --with-nghttp2=$HOME/.local --with-ssl
assert make
assert make install
assert_regex 'nghttp2' ~/.local/bin/curl --version
assert_regex 'libnghttp2.so' ldd ~/.local/bin/curl
assert ~/.local/bin/curl --http2 -I nghttp2.org
assert_regex 'HTTP/2' ~/.local/bin/curl --http2 -I nghttp2.org

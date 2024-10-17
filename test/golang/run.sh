#!/usr/bin/env bash
set -e

script_path=$(readlink -f $(dirname "$0"))
source $script_path/../../util.sh

loginfo "=== start test golang ==="


loginfo "=== test region special $CLOUDIDE_PROVIDER_REGION ==="
if [ "$CLOUDIDE_PROVIDER_REGION" = "cn" ] ;then
    assert_regex "GOPROXY.*https.*goproxy.cn.*direct" go env
else
    loginfo "no region special test, skip"
fi


loginfo "=== test basic env ==="
assert which go
assert which dlv
assert which gofmt
assert which gopls
assert which staticcheck
assert 'arr=(/cloudide/workspace/.cloudide/extensions/golang.go-*) && [ ${#arr[@]} -ne 0 ]'
# assert 'test -e /cloudide/workspace/.cloudide/extensions/xxx-*'
assert_regex "GOROOT=.*nix" go env
assert_regex "GOPATH=.*home/.*/go" go env


loginfo "=== test hello project ==="
cd $script_path/../../data/golang/hello
assert test -e go.mod
assert go get github.com/gin-gonic/gin
assert go mod tidy 
assert go build
assert ./main
assert go run ./
assert go test


loginfo "=== test sample cgo project ==="
cd $script_path/../../data/golang/samplecgo
assert test -e go.mod
assert go build
assert_regex "/nix/store/.*/ld-linux-x86-64.so.2" "ldd ./main | grep ld-linux-x86-64.so.2"
assert ./main
assert '配置特殊 cgo 参数构建，让 deploy 能正常工作' -- "CGO_LDFLAGS='-Wl,-rpath=/lib/x86_64-linux-gnu -Wl,--dynamic-linker=/lib64/ld-linux-x86-64.so.2' go build"
assert_regex_invert "/nix/store/.*/ld-linux-x86-64.so.2" '不应该包含 nix 的 so' -- "ldd ./main | grep ld-linux-x86-64.so.2"

# loginfo "=== test kubernetes project ==="
# cd /tmp && rm -rf kubernetes
# assert git clone --depth 1 https://github.com/kubernetes/kubernetes.git
# cd kubernetes
# assert make
# rm -rf /tmp/kubernetes

loginfo "=== test kubernetes project ==="
cd /tmp && rm -rf gin
assert git clone --depth 1 https://github.com/gin-gonic/gin.git
cd gin
assert go build
assert go test
rm -rf /tmp/gin

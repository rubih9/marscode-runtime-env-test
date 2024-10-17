#!/usr/bin/env bash
set -e


script_path=$(readlink -f $(dirname "$0"))
source $script_path/../../util.sh


clear(){
    loginfo "will clear test data"
    rm -rf $script_path/../../data/java/hello/Main.class
    rm -rf /tmp/test/java
}
trap '[ "$?" -eq 0 ] && clear || true' EXIT
clear


loginfo "=== test region special $CLOUDIDE_PROVIDER_REGION ==="
if [ "$CLOUDIDE_PROVIDER_REGION" = "cn" ] ;then
    assert_regex "maven.aliyun.com" cat ~/.m2/settings.xml
else
    loginfo "no region special test, skip"
fi


loginfo "=== start test basic env ==="
assert which java
assert which mvn
assert which gradle
assert_regex 'redhat.telemetry.enabled.*false' 'cat /cloudide/workspace/.cloudide/data/Machine/settings.json'
assert_regex 'java.jdt.ls.vmargs.*lombok.jar' 'cat /cloudide/workspace/.cloudide/data/Machine/settings.json'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/redhat.java-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/vscjava.vscode-java-debug-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/vscjava.vscode-java-test-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/vscjava.vscode-maven-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/vscjava.vscode-java-dependency-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/vmware.vscode-spring-boot-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/vscjava.vscode-spring-initializr-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/gabrielbb.vscode-lombok-*) && [ ${#arr[@]} -ne 0 ]'
assert_regex "'version.*17.*'" 'java -version 2>&1'
assert_regex "'javac.*17.*'" 'javac -version 2>&1'
assert mvn -v
assert gradle -v

loginfo "=== start test hello ==="
cd $script_path/../../data/java/hello
javac Main.java
java Main


loginfo "=== start test maven and gradle project"
mkdir -p /tmp/test/java
cd /tmp/test/java
if [ "$CLOUDIDE_PROVIDER_REGION" = "cn" ] ;then
    wget https://repo.huaweicloud.com/repository/maven/org/springframework/boot/spring-boot-cli/3.3.2/spring-boot-cli-3.3.2-bin.zip
else
    wget https://repo.maven.apache.org/maven2/org/springframework/boot/spring-boot-cli/3.3.2/spring-boot-cli-3.3.2-bin.zip
fi
unzip -o spring-boot-cli-3.3.2-bin.zip
spring_cmd=$(pwd)/spring-3.3.2/bin/spring
# $spring_cmd init --list
mkdir -p spring-web-maven
cd spring-web-maven
assert $spring_cmd init --type maven-project --dependencies web --extract
assert mvn package
assert_http localhost:8080 404 mvn spring-boot:run
cd /tmp/test/java
mkdir -p spring-web-gradle
cd spring-web-gradle
assert $spring_cmd init --type gradle-project --dependencies web --extract
# https://docs.gradle.org/current/userguide/toolchains.html#sec:custom_loc
# gradle -q javaToolchains
# mkdir -p ~/.gradle
# export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
# export GRADLE_USER_HOME=$HOME/.gradle
# echo 'org.gradle.java.installations.fromEnv=JAVA_HOME' > ~/.gradle/gradle.properties # 不工作，原因是 cat $(which gradle) -P 覆盖了。
# echo "org.gradle.java.installations.paths=$JAVA_HOME" > ~/.gradle/gradle.properties
# ./gradlew -q javaToolchains
# gradle -q javaToolchains
# gradle -Porg.gradle.java.installations.fromEnv=JAVA_HOME -q javaToolchains
# gradle -Porg.gradle.java.installations.paths=/nix/store/zmj3m7wrgqf340vqd4v90w8dw371vhjg-openjdk-17.0.7+7/lib/openjdk -q javaToolchains
assert gradle clean bootJar
assert_http localhost:8080 404 gradle clean bootRun
rm -rf /tmp/test/java


loginfo "=== start test spring-projects/spring-petclinic"
mkdir -p /tmp/test/java
cd /tmp/test/java
if [ "$CLOUDIDE_PROVIDER_REGION" = "cn" ] ;then
    git clone https://gitee.com/rectcircle/spring-petclinic.git
else
    git clone https://github.com/spring-projects/spring-petclinic
fi
cd spring-petclinic && git checkout 383edc1656e305f8151c258b6925df00f7b53655
assert mvn install -Dmaven.test.skip=true
assert_http localhost:8080 200 java -jar target/spring-petclinic-3.3.0-SNAPSHOT.jar
rm -rf /tmp/test/java

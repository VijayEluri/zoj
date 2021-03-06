#!/bin/bash

JUDGE_USER=65533
JUDGE_GROUP=65533

set -eu

function CreateDir() {
    if [ -e "$1" ]; then
        if ! [ -d "$1" ]; then
            echo "$1" exists but is not a directory
            exit 1
        fi
    else
        mkdir "$1"
    fi
    chmod $2 "$1"
}

read -p "Input the directory to install ZOJ judge client [/home/chroot/zoj]:" dir
if [ "$dir" == "" ]; then
    dir="/home/chroot/zoj"
fi
CreateDir "$dir" 755
cp script/start.sh "$dir"
cp script/stop.sh "$dir"
cp script/rotate_log.sh "$dir"
CreateDir "$dir/script" 755
cp script/compile.sh "$dir"/script
cp -f client/judged "$dir"
cp -f client/JavaSandbox.jar "$dir"
cp -f client/libsandbox.so "$dir"
cp -f client/PythonLoader.py "$dir"
cp -f client/PHPLoader.php "$dir"
cp -f client/PerlLoader.pm "$dir"
cp -f client/guile_loader "$dir"
cp -f client/CustomJavaCompiler*.class "$dir"
chmod +x "$dir"/*.sh
chmod +x "$dir"/script/compile.sh
chown -R $JUDGE_USER:$JUDGE_GROUP "$dir"
chown 0:$JUDGE_USER "$dir/judged"
chmod 4710 "$dir/judged"

#if [[ "`cat /etc/group | grep '^zoj:'`" == "" ]]; then
#    groupadd zoj
#fi
#if [[ "`cat /etc/passwd | grep '^zoj:'`" == "" ]]; then
#    useradd -g zoj zoj
#fi
read -p "Create a symlink to rotate_log.sh in /etc/cron.daily? [y/n]" choice
if [ "$choice" == "y" ] || [ "$choice" == "" ]; then
    if ! ln -s "$dir"/rotate_log.sh /etc/cron.daily/rotate_zoj_log; then
        echo "Fail to create the symlink. Please create it manually."
    fi
else
    echo "Remember to put rotate_log.sh in your cron jobs otherwise the log file will be too large"
fi

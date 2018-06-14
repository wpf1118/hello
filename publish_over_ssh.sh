#!/usr/bin/env bash
# 发布环境配置

# bash $WORKSPACE/DeployScript/publish_over_ssh.sh "192.168.31.149" "/data/wwwroot/hello"


PROJECT_DIR="$WORKSPACE/"                                 # 发布工程目录
PACKAGE_NAME=`basename $0 sh`"tar.gz"                     # 打包名称

HOST=$1                                   # 服务器IP
DEPLOY_DIR=$2                             # 部署生产目录
TMP_DIR=${DEPLOY_DIR}"_tmp_dir"           # 部署临时目录


echo ">>>>> 开始发布"

echo "===> 1.打包项目src目录下代码到: ${PACKAGE_NAME} "
tar -czf ${PACKAGE_NAME} src
echo "<=== 1.成功"

echo "===> 2.在远端创建临时目录：${TMP_DIR} "
ssh -p 22 root@${HOST} "mkdir -p ${TMP_DIR} && cd ${TMP_DIR} && pwd"
echo "<=== 2.成功"

echo "3.从发布目录中将打包文件：${PACKAGE_NAME} 拷贝到 ${HOST} 下的临时目录：${TMP_DIR} 中"
scp -P 22 -r ${PACKAGE_NAME} root@${HOST}:${TMP_DIR}
echo "<=== 3.成功"

echo "4.解压项目源码： ${PACKAGE_NAME}"
ssh -p 22 root@${HOST} "cd ${TMP_DIR} && tar -zxf ${PACKAGE_NAME}"
echo "<=== 4.成功"

echo "5.复制项目源码： ${TMP_DIR}/src/ "
ssh -p 22 root@${HOST} "cd ${TMP_DIR} && cp -rf src/. ${DEPLOY_DIR}"
echo "<=== 5.成功"

echo "6.清除临时目录：${TMP_DIR}"
ssh -p 22 root@${HOST} "rm -rf ${TMP_DIR}"
echo "<=== 6.成功"

echo "7.更新 composer 扩展包 - update composer package "
ssh -p 22 root@${HOST} "cd ${DEPLOY_DIR} && pwd && composer update"
echo "<=== 7.成功"

echo "8.递归修改项目根目录权限"
ssh -p 22 root@${HOST} "chown www:www ${DEPLOY_DIR} -R"
echo "<=== 8.成功"

echo "<<<<< 发布结束"

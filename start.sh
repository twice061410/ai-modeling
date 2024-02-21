#!/bin/bash

# 进入maxstudio目录
cd /home/lighthouse/studiomianserver;

# git pull最新代码
git pull

# 构建新的Docker镜像
sudo docker build -t newmaxstudio .

# 停止并删除正在运行的容器
docker stop max-4
docker rm max-4

# 启动新的Docker容器
docker run --name max-4 -d -p 0.0.0.0:3030:3002 --env OPENAI_API_KEY=sk-63MtX6TIQYxMnW9bFd3eDd2a5bDb4768A2393d8758762fF3 --env OPENAI_API_BASE_URL=https://turboapi.chatify.me --env OPENAI_API_MODEL=gpt-4-0613 --restart=always newmaxstudio

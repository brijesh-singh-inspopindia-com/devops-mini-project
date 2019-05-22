#!/bin/bash

cd  /home/ubuntu/
sudo mkdir myapp
cd myapp
sudo touch index.html
sudo chmod 777 index.html
sudo echo "Hi, this is nginx server volumn folder index file" > index.html

sudo docker pull nginx
sudo docker rm -f mynginx
sudo docker run -itd --name=mynginx -v /home/ubuntu/myapp:/usr/share/nginx/html:ro -p 80:80  nginx

[English ReadMe](./README.md)
这个方案使用OpenVpn的方式，解决了mac电脑下无法访问minikube的ip问题，

## Mac电脑下docker的一些网络特性
这里列了一些官方的已知的网络限制 [点击这里](https://docs.docker.com/desktop/mac/networking/#known-limitations-use-cases-and-workarounds)


## 快速开始

通过一下步骤安装访问Minikube的网络

* 安装 [Tunnelblick](https://tunnelblick.net/downloads.html) (一个开源的open vpn 的客户端)
* 运行 `docker-compose up` . 第一次启动的时候会有点慢，因为在生成证书等文件
* 在当前文件夹中，双击生成的 `minikube-for-mac.ovpn` 文件，把这个配置文件添加到Tunnelblick
* 在 Tunnelblick 界面，连接 minikube-for-mac 

执行完上述步骤之后，应该就可以从本地连上minikube内部的网络了

## 实现过程的说明

docker-compose.yml 配置了两个服务，都是基于Alpine Linux 发行版


### openvpn

OpenVPN 的镜像使用的是 [kylemanna/openvpn](https://hub.docker.com/r/kylemanna/openvpn/).

客户端和服务端的配置文件都由`helpers/run.sh`脚本自动生成，这个脚本会设置配置和路由信息，使mac电脑本地可以访问到Minikube的网络


OpenVPN 服务会使用 *host* 网络方式，在docker的虚机里监听1194端口， 这样openVPN 就可以访问docker中的网络（注：mac电脑的docker本质上是运行在一个轻量级虚机中，所以这也导致mac电脑无法和docker网络互通）

mac下的minikube默认是运行在 `192.168.49.0/24` 网段中，在openVPN的路由配置汇总，已经默认添加了这一网段，但是没有添加DNS的配置

OpenVPN的配置文件(`/etc/openvpn/*`)被映射在本地文件夹  `./config/`中，所以即使重启也不用担心配置丢失等问题


### proxy代理

openVPN 是通过*host* 网络方式运行在docker中，因为docker的网络隔离，所以我们无法直接访问到openVPN的端口，这里又启动了一个端口转发的socat服务，并利用docker的端口映射方式，把openVPN的服务暴露出来

## 小技巧

 * Add `restart: always` to both services in `docker-compose.yml` to have them automaticaly restart.
 * To route extra subnets, add extra `route` statements in your `minikube-for-mac.ovpn`
 * To setup static IP addresses for containers, check the `app_net` examples in the [Compose file reference](https://docs.docker.com/compose/compose-file/)
 * To regenerate all files, remove `config/*` and `minikube-for-mac.ovpn`

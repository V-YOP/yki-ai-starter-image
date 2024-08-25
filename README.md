一个用来部署 ai 项目的 docker 项目，基于 nvidia/cuda 镜像，其为一个自带 n 卡显卡驱动的 ubuntu 22.04 系统，大多数系统依赖已安装，并安装 `pyenv` 以方便安装不同版本的 `python`。

`pyenv`，`hugging-face`和`pip`的国内源已配置（用户可能需要做其他网络配置使得最高效，不浪费）。

当前目录下的`opt`和`home`目录映射到容器的`/opt`和`/home`，使用时考虑将 AI 项目和虚拟环境统一置于`/opt`下，这样就不需要每次重新下载安装所有依赖了；映射`/home`是因为`huggingface_hub`会把模型装在`/home/$USERNAME`下。..

同时部署了一个 nginx 用来做反向代理——gradio（把 AI 暴露出 web 界面那家伙）运行时默认只接受本机（即容器）的访问，要修改此行为，（如果该项目没有提供该配置）需要修改 python 代码，这里为了方便直接用反向代理，该代理默认行为是把**对 886X 端口的请求转发给 786X，然后镜像配置时再把本机的 786X 转发给容器的 886X**，这个配置按理来说是不需要再更改的。

# 一般使用流程

## 初始化和启动

1. 保证 docker 安装和启动
2. `git clone`该项目
3. 进入项目文件夹，执行 `docker compose up -d --build`，等待打包和启动
4. 执行 `docker compose exec -it ai-container bash`  进入容器

## 部署 AI 项目

1. 进入容器，进入`/opt`目录
2. `git clone`要部署的 AI 项目，如 [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui)，进入项目文件夹
3. 根据项目文档，安装所需 python 版本，如这里安装`3.10.14`：

```sh
pyenv install 3.10.14
pyenv global 3.10.14
```

每次容器重新创建时，python 需要重新安装。

3. 安装完成后，在项目根目录创建虚拟环境并激活：

```sh
python -m venv .venv
source .venv/bin/activate
```

4. 根据项目文档描述去安装项目所需依赖，启动项目，如果确实系统库，可能需要再次执行`apt install xxx`，可以将相关依赖添加到 Dockerfile 中。

```sh
pip install -r requirements.txt # 一般而言使用该命令安装依赖，Stable Diffusion WebUI 是如此的
```

# 容器相关运维操作

```sh
# 进入容器
docker compose exec -it ai-container bash

# 重新部署容器（会导致需要重新下载 python）（也可用来启动，如果没有更改 Dockerfile 和 docker-compose.yml 的话）
docker compose up -d --build

# 启动容器
docker compose start

# 停止容器（不删除！）
docker compose stop

# 删除容器（删除容器会导致需要重新下载 python）
docker compose down
```

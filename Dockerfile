FROM nvidia/cuda:11.8.0-base-ubuntu22.04

# 更换 APT 源
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime # 避免 tz-data 烦人
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list 

RUN apt update && \
apt install -y \
  wget \
  curl \
  git \
  vim \
  gcc \
  make \
  libgl1 \
  libglib2.0-0 \
  libsndfile1 \
  build-essential \
  libbz2-dev \
  libffi-dev \
  liblzma-dev \
  libncursesw5-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssl-dev \
  libxml2-dev \
  libxmlsec1-dev \
  llvm \
  tk-dev \
  xz-utils \
  zlib1g-dev

# 注意这步会访问github，网络问题需要注意
RUN curl https://pyenv.run | bash   # pyenv 用于管理 python 

# 根据 pyenv 的提示添加下面内容到.bashrc
RUN cat >> ~/.bashrc <<'EOF'
# hf 代理
export HF_ENDPOINT=https://hf-mirror.com

# 这两行是 pyenv 的代理配置
export PYTHON_BUILD_MIRROR_URL_SKIP_CHECKSUM=1
export PYTHON_BUILD_MIRROR_URL="https://registry.npmmirror.com/-/binary/python"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Restart your shell for the changes to take effect.

# Load pyenv-virtualenv automatically by adding
# the following to ~/.bashrc:

eval "$(pyenv virtualenv-init -)"
EOF

# 修改pip镜像源
RUN mkdir -p ~/.config/pip/
RUN cat > ~/.config/pip/pip.conf <<'EOF'
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
EOF


# 使用 sed 转换换行符
RUN sed -i 's/\r//' ~/.bashrc && sed -i 's/\r//' ~/.config/pip/pip.conf

CMD '/bin/bash'

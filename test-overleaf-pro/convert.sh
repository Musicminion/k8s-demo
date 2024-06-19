# !/bin/bash

# 获取当前目录名
# get the current directory name
dirName=$(basename $(pwd))
echo "Mounting repo to /mnt/wsl/$dirName"

# 检查/mnt/wsl/k8s-blast目录是否存在，不存在就创建
# Check if /mnt/wsl/k8s-blast directory exists, if not, create it
if [ ! -d /mnt/wsl/k8s-blast ]; then
    sudo -E mkdir -p /mnt/wsl/$dirName
fi

# 检查/mnt/wsl/k8s-blast目录是否已经挂载，没有挂载就挂载
# Check if /mnt/wsl/k8s-blast directory is already mounted, if not, mount it
if ! mountpoint -q /mnt/wsl/$dirName; then
    sudo -E mount --bind $(pwd) /mnt/wsl/$dirName
    echo "Repo mounted to /mnt/wsl/$dirName finished"
else
    echo "Repo already mounted to /mnt/wsl/$dirName"
fi

# 检查kompose是否已经安装，没有安装就安装
# Check if kompose is already installed, if not, install it
if ! command -v kompose &> /dev/null; then
    echo "kompose not found. Installing kompose..."
    curl -L https://github.com/kubernetes/kompose/releases/download/v1.32.0/kompose-linux-amd64 -o kompose
    chmod +x kompose
    sudo mv ./kompose /usr/local/bin/kompose
fi

# 进入/mnt/wsl/$dirName目录
# cd /mnt/wsl/$dirName
cd /mnt/wsl/$dirName


# 解析命令行参数
# Parse command line arguments
# 如果没有传入参数，默认
# If no parameters are passed in, default
dockerComposeFile="docker-compose.yml"

# 如果传入了参数，使用传入的参数
# If parameters are passed in, use the parameters passed in
if [ $# -gt 0 ]; then
    dockerComposeFile=$1
fi

# 检查docker-compose.yml文件是否存在
# Check if docker-compose.yml file exists
if [ ! -f $dockerComposeFile ]; then
    echo "docker-compose file $dockerComposeFile not found"
    exit 1
fi

# 将docker-compose.yml转换为k8s yaml文件
# Convert docker-compose.yml to k8s yaml file
kompose convert -f $dockerComposeFile -o k8s.$dockerComposeFile --volumes hostPath

# 替换k8s yaml文件中的路径地址
sed -i 's/\/mnt\/wsl/\/run\/desktop\/mnt\/host\/wsl/g' k8s.$dockerComposeFile

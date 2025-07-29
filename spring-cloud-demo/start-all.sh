#!/bin/bash

echo "=== Spring Cloud Demo 启动脚本 ==="

# 检查Java环境
if ! command -v java &> /dev/null; then
    echo "错误: 未找到Java环境，请先安装JDK 11+"
    exit 1
fi

# 检查Maven环境
if ! command -v mvn &> /dev/null; then
    echo "错误: 未找到Maven环境，请先安装Maven 3.6+"
    exit 1
fi

# 编译整个项目
echo "正在编译项目..."
mvn clean compile -q

if [ $? -ne 0 ]; then
    echo "错误: 项目编译失败"
    exit 1
fi

echo "编译完成！"

# 启动服务的函数
start_service() {
    local service_name=$1
    local service_port=$2
    local wait_time=$3
    
    echo "启动 $service_name (端口: $service_port)..."
    cd $service_name
    mvn spring-boot:run > ../logs/${service_name}.log 2>&1 &
    local pid=$!
    echo $pid > ../logs/${service_name}.pid
    cd ..
    
    echo "等待 $service_name 启动 ($wait_time 秒)..."
    sleep $wait_time
    
    # 检查服务是否启动成功
    if curl -s http://localhost:$service_port/actuator/health > /dev/null 2>&1; then
        echo "✓ $service_name 启动成功"
    else
        echo "✗ $service_name 启动失败，请检查日志: logs/${service_name}.log"
    fi
}

# 创建日志目录
mkdir -p logs

echo ""
echo "按照以下顺序启动服务："
echo "1. Eureka Server (注册中心)"
echo "2. Provider Service (服务提供者)"
echo "3. Consumer Service (服务消费者)"
echo "4. Gateway Service (API网关)"
echo ""

# 启动Eureka Server
start_service "eureka-server" "8761" "30"

# 启动Provider Service
start_service "provider-service" "8081" "20"

# 启动Consumer Service
start_service "consumer-service" "8082" "20"

# 启动Gateway Service
start_service "gateway-service" "8080" "20"

echo ""
echo "=== 所有服务启动完成 ==="
echo ""
echo "服务访问地址："
echo "- Eureka Dashboard: http://localhost:8761"
echo "- Provider Service: http://localhost:8081/users"
echo "- Consumer Service: http://localhost:8082/consumer/users"
echo "- Gateway Service: http://localhost:8080/api/provider/users"
echo ""
echo "查看日志："
echo "- tail -f logs/eureka-server.log"
echo "- tail -f logs/provider-service.log"
echo "- tail -f logs/consumer-service.log"
echo "- tail -f logs/gateway-service.log"
echo ""
echo "停止所有服务: ./stop-all.sh"
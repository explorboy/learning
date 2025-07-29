#!/bin/bash

echo "=== 停止 Spring Cloud Demo 所有服务 ==="

# 停止服务的函数
stop_service() {
    local service_name=$1
    local pid_file="logs/${service_name}.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if ps -p $pid > /dev/null 2>&1; then
            echo "停止 $service_name (PID: $pid)..."
            kill $pid
            
            # 等待进程结束
            local count=0
            while ps -p $pid > /dev/null 2>&1 && [ $count -lt 10 ]; do
                sleep 1
                count=$((count + 1))
            done
            
            if ps -p $pid > /dev/null 2>&1; then
                echo "强制停止 $service_name..."
                kill -9 $pid
            fi
            
            echo "✓ $service_name 已停止"
        else
            echo "⚠ $service_name 进程不存在 (PID: $pid)"
        fi
        rm -f "$pid_file"
    else
        echo "⚠ 未找到 $service_name 的PID文件"
    fi
}

# 按相反顺序停止服务
echo "按照以下顺序停止服务："
echo "1. Gateway Service"
echo "2. Consumer Service"
echo "3. Provider Service"
echo "4. Eureka Server"
echo ""

stop_service "gateway-service"
stop_service "consumer-service"
stop_service "provider-service"
stop_service "eureka-server"

# 清理可能遗留的Java进程
echo ""
echo "检查是否还有相关的Java进程..."
PROCESSES=$(ps aux | grep -E "(eureka-server|provider-service|consumer-service|gateway-service)" | grep -v grep | grep java)

if [ ! -z "$PROCESSES" ]; then
    echo "发现遗留进程："
    echo "$PROCESSES"
    echo ""
    echo "是否强制杀死这些进程? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "$PROCESSES" | awk '{print $2}' | xargs kill -9
        echo "✓ 已强制停止所有相关进程"
    fi
else
    echo "✓ 没有发现遗留进程"
fi

echo ""
echo "=== 所有服务已停止 ==="
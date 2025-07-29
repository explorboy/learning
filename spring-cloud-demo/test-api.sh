#!/bin/bash

echo "=== Spring Cloud Demo API 测试脚本 ==="

# 检查服务是否运行
check_service() {
    local service_name=$1
    local port=$2
    local endpoint=$3
    
    echo "检查 $service_name (端口: $port)..."
    if curl -s "http://localhost:$port$endpoint" > /dev/null; then
        echo "✓ $service_name 运行正常"
        return 0
    else
        echo "✗ $service_name 未运行或无法访问"
        return 1
    fi
}

# 执行API测试
test_api() {
    local method=$1
    local url=$2
    local data=$3
    local description=$4
    
    echo ""
    echo "--- $description ---"
    echo "请求: $method $url"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "HTTP_CODE:%{http_code}" "$url")
    elif [ "$method" = "POST" ]; then
        response=$(curl -s -w "HTTP_CODE:%{http_code}" -X POST -H "Content-Type: application/json" -d "$data" "$url")
    elif [ "$method" = "DELETE" ]; then
        response=$(curl -s -w "HTTP_CODE:%{http_code}" -X DELETE "$url")
    fi
    
    http_code=$(echo "$response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
    body=$(echo "$response" | sed 's/HTTP_CODE:[0-9]*$//')
    
    echo "响应码: $http_code"
    if [ ! -z "$body" ]; then
        echo "响应体: $body"
    fi
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo "✓ 测试通过"
    else
        echo "✗ 测试失败"
    fi
}

echo ""
echo "第一步: 检查所有服务状态..."

# 检查服务状态
eureka_ok=$(check_service "Eureka Server" "8761" "/")
provider_ok=$(check_service "Provider Service" "8081" "/actuator/health")
consumer_ok=$(check_service "Consumer Service" "8082" "/actuator/health")
gateway_ok=$(check_service "Gateway Service" "8080" "/actuator/health")

if ! $eureka_ok || ! $provider_ok || ! $consumer_ok || ! $gateway_ok; then
    echo ""
    echo "错误: 部分服务未运行，请先启动所有服务："
    echo "./start-all.sh"
    exit 1
fi

echo ""
echo "第二步: 测试直接访问服务..."

# 测试Provider Service
test_api "GET" "http://localhost:8081/users" "" "获取所有用户 (Provider)"
test_api "GET" "http://localhost:8081/users/1" "" "获取用户ID=1 (Provider)"
test_api "POST" "http://localhost:8081/users" '{"name":"测试用户","email":"test@example.com","age":30}' "添加新用户 (Provider)"
test_api "GET" "http://localhost:8081/users/health" "" "Provider健康检查"

# 测试Consumer Service
test_api "GET" "http://localhost:8082/consumer/users" "" "通过Consumer获取所有用户"
test_api "GET" "http://localhost:8082/consumer/users/1" "" "通过Consumer获取用户ID=1"
test_api "POST" "http://localhost:8082/consumer/users" '{"name":"Consumer测试用户","email":"consumer@example.com","age":25}' "通过Consumer添加新用户"
test_api "GET" "http://localhost:8082/consumer/health" "" "Consumer检查Provider健康状态"
test_api "GET" "http://localhost:8082/consumer/status" "" "Consumer自身状态检查"

echo ""
echo "第三步: 测试通过网关访问服务..."

# 测试Gateway路由
test_api "GET" "http://localhost:8080/api/provider/users" "" "通过网关访问Provider获取所有用户"
test_api "GET" "http://localhost:8080/api/provider/users/1" "" "通过网关访问Provider获取用户ID=1"
test_api "POST" "http://localhost:8080/api/provider/users" '{"name":"网关测试用户","email":"gateway@example.com","age":28}' "通过网关向Provider添加新用户"

test_api "GET" "http://localhost:8080/api/consumer/users" "" "通过网关访问Consumer获取所有用户"
test_api "GET" "http://localhost:8080/api/consumer/health" "" "通过网关访问Consumer健康检查"

echo ""
echo "第四步: 测试服务发现和监控端点..."

test_api "GET" "http://localhost:8761/eureka/apps" "" "Eureka注册的应用列表"
test_api "GET" "http://localhost:8080/actuator/gateway/routes" "" "Gateway路由配置"

echo ""
echo "=== API测试完成 ==="
echo ""
echo "手动测试建议："
echo "1. 访问 Eureka Dashboard: http://localhost:8761"
echo "2. 查看注册的服务实例"
echo "3. 测试服务发现功能"
echo "4. 观察网关日志中的请求记录"
# Spring Cloud 微服务演示项目

这是一个基于Spring Cloud的微服务架构演示项目，包含服务注册中心、服务提供者、服务消费者和API网关。

## 项目结构

```
spring-cloud-demo/
├── eureka-server/          # Eureka服务注册中心 (端口: 8761)
├── provider-service/       # 服务提供者 (端口: 8081)
├── consumer-service/       # 服务消费者 (端口: 8082)
├── gateway-service/        # API网关 (端口: 8080)
└── pom.xml                # 父级Maven配置
```

## 技术栈

- **Spring Boot**: 2.7.18
- **Spring Cloud**: 2021.0.8
- **Eureka**: 服务注册与发现
- **OpenFeign**: 服务间调用
- **Spring Cloud Gateway**: API网关
- **Maven**: 依赖管理

## 服务说明

### 1. Eureka Server (eureka-server)
- **端口**: 8761
- **功能**: 服务注册中心，负责服务的注册与发现
- **访问地址**: http://localhost:8761

### 2. Provider Service (provider-service)
- **端口**: 8081
- **功能**: 服务提供者，提供用户管理相关API
- **主要API**:
  - `GET /users` - 获取所有用户
  - `GET /users/{id}` - 根据ID获取用户
  - `POST /users` - 添加用户
  - `DELETE /users/{id}` - 删除用户
  - `GET /users/health` - 健康检查

### 3. Consumer Service (consumer-service)
- **端口**: 8082
- **功能**: 服务消费者，通过Feign调用Provider Service
- **主要API**:
  - `GET /consumer/users` - 通过消费者获取所有用户
  - `GET /consumer/users/{id}` - 通过消费者根据ID获取用户
  - `POST /consumer/users` - 通过消费者添加用户
  - `DELETE /consumer/users/{id}` - 通过消费者删除用户
  - `GET /consumer/health` - 检查提供者服务状态
  - `GET /consumer/status` - 消费者服务状态

### 4. Gateway Service (gateway-service)
- **端口**: 8080
- **功能**: API网关，统一入口和路由分发
- **路由规则**:
  - `/api/provider/**` → provider-service
  - `/api/consumer/**` → consumer-service
  - `/eureka/**` → eureka-server

## 启动顺序

1. **启动Eureka Server**
   ```bash
   cd eureka-server
   mvn spring-boot:run
   ```

2. **启动Provider Service**
   ```bash
   cd provider-service
   mvn spring-boot:run
   ```

3. **启动Consumer Service**
   ```bash
   cd consumer-service
   mvn spring-boot:run
   ```

4. **启动Gateway Service**
   ```bash
   cd gateway-service
   mvn spring-boot:run
   ```

## 测试API

### 直接访问服务

**Provider Service**:
```bash
# 获取所有用户
curl http://localhost:8081/users

# 根据ID获取用户
curl http://localhost:8081/users/1

# 添加用户
curl -X POST http://localhost:8081/users \
  -H "Content-Type: application/json" \
  -d '{"name":"新用户","email":"new@example.com","age":25}'
```

**Consumer Service**:
```bash
# 通过消费者获取所有用户
curl http://localhost:8082/consumer/users

# 检查提供者服务状态
curl http://localhost:8082/consumer/health
```

### 通过网关访问

```bash
# 通过网关访问提供者服务
curl http://localhost:8080/api/provider/users

# 通过网关访问消费者服务
curl http://localhost:8080/api/consumer/users

# 访问Eureka管理界面
curl http://localhost:8080/eureka/
```

## 监控和健康检查

- **Eureka Dashboard**: http://localhost:8761
- **Provider Health**: http://localhost:8081/actuator/health
- **Consumer Health**: http://localhost:8082/actuator/health
- **Gateway Health**: http://localhost:8080/actuator/health
- **Gateway Routes**: http://localhost:8080/actuator/gateway/routes

## 核心特性演示

1. **服务注册与发现**: 所有服务都会注册到Eureka服务中心
2. **负载均衡**: 通过Ribbon/LoadBalancer实现客户端负载均衡
3. **服务间调用**: Consumer通过Feign客户端调用Provider服务
4. **API网关**: 统一入口，路由分发，请求日志记录
5. **健康检查**: 所有服务都提供健康检查端点

## 开发环境要求

- JDK 11+
- Maven 3.6+
- IDE (推荐IntelliJ IDEA或Eclipse)

## 注意事项

1. 启动顺序很重要，建议按照上述顺序启动服务
2. 确保各服务端口未被占用
3. 如需修改端口，请同步修改相关配置文件中的地址
4. 生产环境建议关闭Eureka的自我保护机制配置
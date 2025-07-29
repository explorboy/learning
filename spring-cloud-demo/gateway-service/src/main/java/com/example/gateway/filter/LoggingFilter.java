package com.example.gateway.filter;

import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;

/**
 * 全局日志过滤器
 */
@Component
public class LoggingFilter implements GlobalFilter, Ordered {

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        String path = request.getPath().value();
        String method = request.getMethod().name();
        String clientIp = request.getRemoteAddress() != null ? 
                         request.getRemoteAddress().getAddress().getHostAddress() : "unknown";

        System.out.println("=== Gateway Log ===");
        System.out.println("Time: " + LocalDateTime.now());
        System.out.println("Method: " + method);
        System.out.println("Path: " + path);
        System.out.println("Client IP: " + clientIp);
        System.out.println("Headers: " + request.getHeaders().toSingleValueMap());
        System.out.println("==================");

        return chain.filter(exchange);
    }

    @Override
    public int getOrder() {
        return -1; // 确保这个过滤器优先执行
    }
}
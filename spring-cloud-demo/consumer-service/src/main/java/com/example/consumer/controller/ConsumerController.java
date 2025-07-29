package com.example.consumer.controller;

import com.example.consumer.entity.User;
import com.example.consumer.service.ConsumerUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 消费者控制器
 */
@RestController
@RequestMapping("/consumer")
public class ConsumerController {

    @Autowired
    private ConsumerUserService consumerUserService;

    @Value("${server.port}")
    private String port;

    /**
     * 通过消费者获取所有用户
     */
    @GetMapping("/users")
    public ResponseEntity<List<User>> getAllUsers() {
        List<User> users = consumerUserService.getAllUsers();
        System.out.println("消费者服务(端口:" + port + ")调用提供者服务获取用户列表");
        return ResponseEntity.ok(users);
    }

    /**
     * 通过消费者根据ID获取用户
     */
    @GetMapping("/users/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        User user = consumerUserService.getUserById(id);
        System.out.println("消费者服务(端口:" + port + ")调用提供者服务获取用户ID: " + id);
        if (user != null) {
            return ResponseEntity.ok(user);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * 通过消费者添加用户
     */
    @PostMapping("/users")
    public ResponseEntity<User> addUser(@RequestBody User user) {
        User savedUser = consumerUserService.addUser(user);
        System.out.println("消费者服务(端口:" + port + ")调用提供者服务添加用户: " + savedUser);
        return ResponseEntity.ok(savedUser);
    }

    /**
     * 通过消费者删除用户
     */
    @DeleteMapping("/users/{id}")
    public ResponseEntity<String> deleteUser(@PathVariable Long id) {
        boolean deleted = consumerUserService.deleteUser(id);
        System.out.println("消费者服务(端口:" + port + ")调用提供者服务删除用户ID: " + id + ", 结果: " + deleted);
        if (deleted) {
            return ResponseEntity.ok("用户删除成功");
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * 检查提供者服务状态
     */
    @GetMapping("/health")
    public ResponseEntity<String> checkHealth() {
        String healthStatus = consumerUserService.checkProviderHealth();
        System.out.println("消费者服务(端口:" + port + ")检查提供者服务健康状态: " + healthStatus);
        return ResponseEntity.ok("Consumer Service (Port: " + port + ") -> " + healthStatus);
    }

    /**
     * 消费者服务本身的健康检查
     */
    @GetMapping("/status")
    public ResponseEntity<String> status() {
        return ResponseEntity.ok("Consumer Service is running on port: " + port);
    }
}
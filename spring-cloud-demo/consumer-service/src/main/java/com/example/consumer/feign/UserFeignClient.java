package com.example.consumer.feign;

import com.example.consumer.entity.User;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 用户服务Feign客户端
 */
@FeignClient(name = "provider-service")
public interface UserFeignClient {

    /**
     * 获取所有用户
     */
    @GetMapping("/users")
    ResponseEntity<List<User>> getAllUsers();

    /**
     * 根据ID获取用户
     */
    @GetMapping("/users/{id}")
    ResponseEntity<User> getUserById(@PathVariable("id") Long id);

    /**
     * 添加用户
     */
    @PostMapping("/users")
    ResponseEntity<User> addUser(@RequestBody User user);

    /**
     * 删除用户
     */
    @DeleteMapping("/users/{id}")
    ResponseEntity<Void> deleteUser(@PathVariable("id") Long id);

    /**
     * 健康检查
     */
    @GetMapping("/users/health")
    ResponseEntity<String> health();
}
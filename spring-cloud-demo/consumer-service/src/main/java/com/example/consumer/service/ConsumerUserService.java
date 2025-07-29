package com.example.consumer.service;

import com.example.consumer.entity.User;
import com.example.consumer.feign.UserFeignClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 消费者用户服务类
 */
@Service
public class ConsumerUserService {

    @Autowired
    private UserFeignClient userFeignClient;

    /**
     * 获取所有用户
     */
    public List<User> getAllUsers() {
        ResponseEntity<List<User>> response = userFeignClient.getAllUsers();
        return response.getBody();
    }

    /**
     * 根据ID获取用户
     */
    public User getUserById(Long id) {
        ResponseEntity<User> response = userFeignClient.getUserById(id);
        return response.getBody();
    }

    /**
     * 添加用户
     */
    public User addUser(User user) {
        ResponseEntity<User> response = userFeignClient.addUser(user);
        return response.getBody();
    }

    /**
     * 删除用户
     */
    public boolean deleteUser(Long id) {
        try {
            userFeignClient.deleteUser(id);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 检查提供者服务健康状态
     */
    public String checkProviderHealth() {
        try {
            ResponseEntity<String> response = userFeignClient.health();
            return response.getBody();
        } catch (Exception e) {
            return "Provider service is not available";
        }
    }
}
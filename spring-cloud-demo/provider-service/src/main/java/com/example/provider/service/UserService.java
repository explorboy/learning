package com.example.provider.service;

import com.example.provider.entity.User;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * 用户服务类
 */
@Service
public class UserService {

    private static final List<User> users = new ArrayList<>();

    static {
        // 初始化一些测试数据
        users.add(new User(1L, "张三", "zhangsan@example.com", 25));
        users.add(new User(2L, "李四", "lisi@example.com", 30));
        users.add(new User(3L, "王五", "wangwu@example.com", 28));
    }

    /**
     * 获取所有用户
     */
    public List<User> getAllUsers() {
        return new ArrayList<>(users);
    }

    /**
     * 根据ID获取用户
     */
    public Optional<User> getUserById(Long id) {
        return users.stream()
                .filter(user -> user.getId().equals(id))
                .findFirst();
    }

    /**
     * 添加用户
     */
    public User addUser(User user) {
        // 自动生成ID
        Long maxId = users.stream()
                .mapToLong(User::getId)
                .max()
                .orElse(0L);
        user.setId(maxId + 1);
        users.add(user);
        return user;
    }

    /**
     * 删除用户
     */
    public boolean deleteUser(Long id) {
        return users.removeIf(user -> user.getId().equals(id));
    }
}
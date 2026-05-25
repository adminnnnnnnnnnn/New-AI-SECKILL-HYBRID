
package com.seckill.user.controller;

import com.seckill.common.vo.Result;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/user")
public class UserController {

    @GetMapping("/{userId}")
    public Result<Map<String, Object>> getUser(@PathVariable Long userId) {
        Map<String, Object> user = new HashMap<>();
        user.put("id", userId);
        user.put("username", "user_" + userId);
        user.put("email", "user" + userId + "@example.com");
        return Result.success(user);
    }

    @PostMapping("/validate")
    public Result<Boolean> validateUser(@RequestParam Long userId) {
        return Result.success(userId > 0 && userId < 10000);
    }
}

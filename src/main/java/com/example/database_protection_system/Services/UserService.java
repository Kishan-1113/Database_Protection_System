package com.example.database_protection_system.Services;

import com.example.database_protection_system.Exceptions.InvalidUserDataException;
import com.example.database_protection_system.Exceptions.ResourceNotFoundException;
import com.example.database_protection_system.Exceptions.UserAlreadyExistsException;
import com.example.database_protection_system.Model.UserData;
import com.example.database_protection_system.Repository.UserRepository;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserData saveUser(UserData user) {
        if (user == null
                || isBlank(user.getFirstName())
                || isBlank(user.getLastName())
                || isBlank(user.getEmail())
                || isBlank(user.getPhoneNumber())
                || isBlank(user.getAddress())
                || isBlank(user.getCity())) {
            throw new InvalidUserDataException("All six user fields are required");
        }
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new UserAlreadyExistsException(user.getEmail());
        }
        return userRepository.saveAndFlush(user);
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    public UserData getUserByEmail(String email) {
        if (isBlank(email)) {
            throw new InvalidUserDataException("Email is required");
        }
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("No user found with email " + email));
    }
}

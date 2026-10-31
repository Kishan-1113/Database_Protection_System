package com.example.database_protection_system.Exceptions;

public class UserAlreadyExistsException extends RuntimeException {
    public UserAlreadyExistsException(String email) {
        super("A user with email " + email + " already exists");
    }
}

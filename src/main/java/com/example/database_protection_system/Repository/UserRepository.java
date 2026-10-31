package com.example.database_protection_system.Repository;

import com.example.database_protection_system.Model.UserData;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<UserData, Long> {
    boolean existsByEmail(String email);

    Optional<UserData> findByEmail(String email);
}

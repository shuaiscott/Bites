package com.bites.fruit.repository;

import com.bites.fruit.model.Bite;

import org.springframework.data.jpa.repository.JpaRepository;

public interface IBiteRepository extends JpaRepository<Bite, Long> {
}

package com.bites.fruit.repository;

import java.util.UUID;

import com.bites.fruit.model.Meal;

import org.springframework.data.jpa.repository.JpaRepository;

public interface IMealRepository extends JpaRepository<Meal, UUID> {
}

package com.bites.fruit.repository;

import com.bites.fruit.model.Fruit;

import org.springframework.data.jpa.repository.JpaRepository;

public interface IFruitRepository extends JpaRepository<Fruit, Integer> {
    Fruit findByName(String name);
}

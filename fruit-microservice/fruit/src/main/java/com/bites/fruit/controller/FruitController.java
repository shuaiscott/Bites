package com.bites.fruit.controller;

import java.util.List;

import com.bites.fruit.model.Fruit;
import com.bites.fruit.repository.IFruitRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class FruitController {
	
    @Autowired
    private IFruitRepository repository;

	@GetMapping("/fruits")
	public ResponseEntity<List<Fruit>> getFruits() {
		List<Fruit> fruits = repository.findAll();
        return new ResponseEntity<>(fruits, HttpStatus.OK);    
    }
}
package com.bites.fruit.controller;

import java.util.Optional;
import java.util.UUID;

import com.bites.fruit.dto.MealDto;
import com.bites.fruit.model.Bite;
import com.bites.fruit.model.Fruit;
import com.bites.fruit.model.Meal;
import com.bites.fruit.repository.IBiteRepository;
import com.bites.fruit.repository.IFruitRepository;
import com.bites.fruit.repository.IMealRepository;

import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MealsController {
	
    @Autowired
    private IMealRepository mealRepository;

    @Autowired
    private IBiteRepository biteRepository;

    @Autowired
    private IFruitRepository fruitRepository;

    @Autowired
    private ModelMapper modelMapper;

    @GetMapping("/meals/{mealId}")
	public ResponseEntity<MealDto> getMeal(@PathVariable UUID mealId) {
        Optional<Meal> meal = mealRepository.findById(mealId);
        if(!meal.isPresent())
        {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        return new ResponseEntity<>(convertToDto(meal.get()), HttpStatus.OK);
    }

	@PostMapping("/meals")
	public ResponseEntity<MealDto> createMeal(@RequestBody MealDto dto) {
        Optional<Fruit> fruit = fruitRepository.findById(dto.getFruitId());
        if(!fruit.isPresent())
        {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        Meal meal = new Meal(fruit.get());
        meal = mealRepository.saveAndFlush(meal);
        return new ResponseEntity<>(convertToDto(meal), HttpStatus.OK);
    }

    @PostMapping("/meals/{mealId}/bite")
    public ResponseEntity<MealDto> biteMeal(@PathVariable UUID mealId) {
        Optional<Meal> meal = mealRepository.findById(mealId);
        if(!meal.isPresent())
        {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        Meal foundMeal = meal.get();
        if (foundMeal.getBitesLeft() > 0) 
        {
            foundMeal.biteMeal();
            Bite bite = new Bite(foundMeal);
            bite.setIpAddress("ipAddress");
            biteRepository.saveAndFlush(bite);
            return new ResponseEntity<>(convertToDto(foundMeal), HttpStatus.OK);
        }
        else
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    private MealDto convertToDto(Meal meal) {
        MealDto mealDto =  modelMapper.map(meal, MealDto.class);
        mealDto.setFruitId(meal.getFruit().getId());
        return mealDto;
    }
}
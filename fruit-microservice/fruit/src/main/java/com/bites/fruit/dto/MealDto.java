package com.bites.fruit.dto;

import java.util.UUID;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class MealDto {
    private UUID id;
    private int fruitId;
    private int bitesLeft;
}
package com.bites.fruit.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.NonNull;

@Data
@NoArgsConstructor
@Entity
@Table(name = "fruits")
public class Fruit {
    @Id 
    @GeneratedValue 
    @Column(name = "id")
    private long id;

	@NonNull 
    @Column(name = "name")
    private String name;

    @Column(name = "totalbites")
    private int totalBites;
}
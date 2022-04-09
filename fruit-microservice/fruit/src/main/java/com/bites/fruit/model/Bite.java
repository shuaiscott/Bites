package com.bites.fruit.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.validation.constraints.Size;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.NonNull;

@Data
@NoArgsConstructor
@Entity
@Table(name = "bites")
public class Bite {
    @Id 
    @GeneratedValue  
    @Column(name = "id")
    private long id;

	@NonNull 
    @Column(name = "ipaddress", length = 15) 
    @Size(min = 7, max = 15)
    private String ipAddress;

}
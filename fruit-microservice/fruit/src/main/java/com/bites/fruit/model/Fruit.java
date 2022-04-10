package com.bites.fruit.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EntityListeners;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.NonNull;

@Entity
@EntityListeners(AuditingEntityListener.class)
@Table(name = "fruits")
@Data
@NoArgsConstructor
public class Fruit {
    @Id 
    @GeneratedValue 
    @Column(name = "id")
    private int id;

	@NonNull 
    @Column(name = "name")
    private String name;

    @Column(name = "total_bites")
    private int totalBites;

    @CreatedDate
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "created_date", nullable = false, updatable = false)
    private Date createdDate;
}
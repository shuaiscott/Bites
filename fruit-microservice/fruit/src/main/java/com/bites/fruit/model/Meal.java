package com.bites.fruit.model;

import java.util.Date;
import java.util.UUID;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EntityListeners;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import org.hibernate.annotations.GenericGenerator;
import org.hibernate.annotations.Parameter;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.NonNull;

@Entity
@EntityListeners(AuditingEntityListener.class)
@Table(name = "meals")
@Data
@NoArgsConstructor
public class Meal {
    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
        name = "UUID",
        strategy = "org.hibernate.id.UUIDGenerator",
        parameters = {
            @Parameter(
                name = "uuid_gen_strategy_class",
                value = "org.hibernate.id.uuid.CustomVersionOneStrategy"
            )
        }
    )
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @CreatedDate
    @Column(name = "created_date", nullable = false, updatable = false)
    private Date createdDate;

    @Column(name = "bites_left", nullable = false)
    private int bitesLeft;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fruit_id", nullable = false, updatable = false)
    @NonNull
    private Fruit fruit;

    public Meal(Fruit fruit)
    {
        this.fruit = fruit;
        this.bitesLeft = fruit.getTotalBites();
    }

    public void biteMeal()
    {
        this.bitesLeft--;
    }
}
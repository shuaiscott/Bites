package com.bites.fruit;

import org.flywaydb.core.Flyway;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class FruitApplication {

	public static void main(String[] args) {
		Flyway flyway = Flyway.configure()
		// TODO replace with env vars
			.dataSource("jdbc:postgresql://localhost:5432/fruit", "scott", "")
			.load();
		flyway.migrate();

		SpringApplication.run(FruitApplication.class, args);
	}

}

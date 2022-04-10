package com.bites.fruit.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.modelmapper.ModelMapper;

@Configuration
@EnableJpaAuditing
public class ApplicationConfig {

   @Bean
   public ModelMapper modelmapper() {
        return new ModelMapper();
   }
}
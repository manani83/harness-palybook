package kr.co.harness.spm;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class SpmApplication {

    public static void main(String[] args) {
        SpringApplication.run(SpmApplication.class, args);
    }
}

package kg.bishkek.fucent.fusent.config;

import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.OpenAPI;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {
    @Bean
    public OpenAPI fusentOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Fusent API")
                        .description("Marketplace backend API documentation")
                        .version("1.0.0"));
    }
}

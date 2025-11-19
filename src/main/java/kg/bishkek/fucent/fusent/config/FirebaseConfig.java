package kg.bishkek.fucent.fusent.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import java.io.IOException;
import java.io.InputStream;

@Slf4j
@Configuration
public class FirebaseConfig {

    @Value("${firebase.config.file:firebase-adminsdk.json}")
    private String firebaseConfigPath;

    @PostConstruct
    public void initialize() {
        try {
            // Try to load Firebase config from classpath
            ClassPathResource resource = new ClassPathResource(firebaseConfigPath);

            if (resource.exists()) {
                try (InputStream serviceAccount = resource.getInputStream()) {
                    FirebaseOptions options = FirebaseOptions.builder()
                            .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                            .build();

                    if (FirebaseApp.getApps().isEmpty()) {
                        FirebaseApp.initializeApp(options);
                        log.info("Firebase Admin SDK initialized successfully");
                    }
                }
            } else {
                log.warn("Firebase config file not found: {}. Push notifications will not work.", firebaseConfigPath);
                log.warn("To enable push notifications, add firebase-adminsdk.json to src/main/resources/");
            }
        } catch (IOException e) {
            log.error("Failed to initialize Firebase Admin SDK", e);
            log.warn("Push notifications will not work without proper Firebase configuration");
        }
    }
}

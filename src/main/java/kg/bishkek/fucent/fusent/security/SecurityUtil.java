package kg.bishkek.fucent.fusent.security;

import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.UUID;

@Slf4j
public class SecurityUtil {

    public static String currentEmail() {
        Authentication a = SecurityContextHolder.getContext().getAuthentication();
        log.info("SecurityUtil.currentEmail() - Authentication: {}", a);
        if (a != null) {
            log.info("Authentication details - name: {}, principal: {}, authenticated: {}",
                a.getName(), a.getPrincipal(), a.isAuthenticated());
        }
        return a == null ? null : a.getName();
    }

    public static UUID currentUserId(AppUserRepository users) {
        var email = currentEmail();
        log.info("SecurityUtil.currentUserId() - email from Authentication: {}", email);

        if (email == null) {
            log.error("Email is NULL - user not authenticated!");
            throw new RuntimeException("User not authenticated - email is null");
        }

        var userOpt = users.findByEmail(email);
        log.info("User found in database: {}", userOpt.isPresent());

        if (userOpt.isEmpty()) {
            log.error("User not found in database for email: {}", email);
            throw new RuntimeException("User not found for email: " + email);
        }

        var u = userOpt.get();
        log.info("User ID: {}, Email: {}", u.getId(), u.getEmail());
        return u.getId();
    }
}

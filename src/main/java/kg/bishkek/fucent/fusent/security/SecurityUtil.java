package kg.bishkek.fucent.fusent.security;

import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.UUID;

public class SecurityUtil {

    public static String currentEmail() {
        Authentication a = SecurityContextHolder.getContext().getAuthentication();
        return a == null ? null : a.getName();
    }

    public static UUID currentUserId(AppUserRepository users) {
        var email = currentEmail();
        var u = users.findByEmail(email).orElseThrow();
        return u.getId();
    }
}

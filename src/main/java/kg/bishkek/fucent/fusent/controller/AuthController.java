package kg.bishkek.fucent.fusent.controller;



import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.security.AuthDtos;
import kg.bishkek.fucent.fusent.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AppUserRepository users;
    private final PasswordEncoder encoder;
    private final JwtService jwt;
    private final AuthenticationManager authManager;


    @PostMapping("/register")
    public AuthDtos.JwtResponse register(@Valid @RequestBody AuthDtos.RegisterRequest req) {
        if (users.findByEmail(req.email()).isPresent()) throw new IllegalArgumentException("email exists");
        var u = AppUser.builder().email(req.email()).passwordHash(encoder.encode(req.password())).role(req.role()).build();
        users.save(u);
        String token = jwt.generate(u.getEmail(), u.getRole().name());
        return new AuthDtos.JwtResponse(token);
    }


    @PostMapping("/login")
    public AuthDtos.JwtResponse login(@Valid @RequestBody AuthDtos.LoginRequest req) {
        authManager.authenticate(new UsernamePasswordAuthenticationToken(req.email(), req.password()));
        var user = users.findByEmail(req.email()).orElseThrow();
        String token = jwt.generate(user.getEmail(), user.getRole().name());
        return new AuthDtos.JwtResponse(token);
    }
}
package kg.bishkek.fucent.fusent.common;

import org.springframework.http.HttpStatus;


public record ApiError(HttpStatus status, String code, String message) {}
package kg.bishkek.fucent.fusent.common;



import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;


@RestControllerAdvice
public class GlobalExceptionHandler {


    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiError> handleValidation(MethodArgumentNotValidException ex) {
        var msg = ex.getBindingResult().getAllErrors().stream().findFirst().map(e -> e.getDefaultMessage()).orElse("Validation error");
        return ResponseEntity.badRequest().body(new ApiError(HttpStatus.BAD_REQUEST, "VALIDATION_ERROR", msg));
    }


    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiError> handleIllegalArg(IllegalArgumentException ex) {
        return ResponseEntity.badRequest().body(new ApiError(HttpStatus.BAD_REQUEST, "BAD_REQUEST", ex.getMessage()));
    }
}

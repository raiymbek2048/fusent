package kg.bishkek.fucent.fusent.controller;



import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.PosSaleRequest;
import kg.bishkek.fucent.fusent.service.PosService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/api/v1/pos")
@RequiredArgsConstructor
public class PosController {
    private final PosService service;


    @PostMapping("/sales")
    public void sales(@Valid @RequestBody PosSaleRequest req) { service.recordSale(req); }
}
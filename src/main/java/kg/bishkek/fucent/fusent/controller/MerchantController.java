package kg.bishkek.fucent.fusent.controller;



import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.MerchantCreateRequest;
import kg.bishkek.fucent.fusent.dto.MerchantResponse;
import kg.bishkek.fucent.fusent.model.Merchant;
import kg.bishkek.fucent.fusent.service.MerchantService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;


import java.util.List;
import java.util.UUID;


@RestController
@RequestMapping("/api/v1/merchants")
@RequiredArgsConstructor
public class MerchantController {
    private final MerchantService service;


    @PostMapping
    public MerchantResponse create(@Valid @RequestBody MerchantCreateRequest req) { return service.create(req); }


    @GetMapping
    public List<MerchantResponse> list() { return service.list(); }


    @GetMapping("/{id}")
    public Merchant get(@PathVariable UUID id) { return service.get(id); }
}
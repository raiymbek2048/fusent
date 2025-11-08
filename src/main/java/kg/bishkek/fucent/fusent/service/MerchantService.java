package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.MerchantCreateRequest;
import kg.bishkek.fucent.fusent.dto.MerchantResponse;
import kg.bishkek.fucent.fusent.model.Merchant;

import java.util.List;
import java.util.UUID;

public interface MerchantService {
    MerchantResponse create(MerchantCreateRequest req);

    List<MerchantResponse> list();

    Merchant get(UUID id);
}

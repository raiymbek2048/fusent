// kg/bishkek/fucent/fusent/service/impl/MerchantServiceImpl.java
package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.MerchantCreateRequest;
import kg.bishkek.fucent.fusent.dto.MerchantResponse;
import kg.bishkek.fucent.fusent.model.Merchant;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.MerchantRepository;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import kg.bishkek.fucent.fusent.service.MerchantService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MerchantServiceImpl implements MerchantService {
    private final MerchantRepository merchantRepository;
    private final AppUserRepository users;

    @Override
    public MerchantResponse create(MerchantCreateRequest req) {
        var ownerId = SecurityUtil.currentUserId(users);
        var m = Merchant.builder()
                .ownerUserId(ownerId)
                .name(req.name())
                .description(req.description())
                .build();
        m = merchantRepository.save(m);
        return new MerchantResponse(m.getId(), m.getName(), m.getDescription(), m.getPayoutStatus(), m.getBuyEligibility());
    }

    @Override
    public List<MerchantResponse> list() {
        return merchantRepository.findAll().stream()
                .map(m -> new MerchantResponse(m.getId(), m.getName(), m.getDescription(), m.getPayoutStatus(), m.getBuyEligibility()))
                .toList();
    }

    @Override
    public Merchant get(UUID id) {
        return merchantRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("merchant not found"));
    }
}

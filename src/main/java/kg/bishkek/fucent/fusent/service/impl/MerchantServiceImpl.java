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
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class MerchantServiceImpl implements MerchantService {
    private final MerchantRepository merchantRepository;
    private final AppUserRepository users;

    @Override
    public MerchantResponse create(MerchantCreateRequest req) {
        log.info("=== Creating merchant ===");
        log.info("Request: name={}, description={}", req.name(), req.description());

        UUID ownerId = null;
        try {
            ownerId = SecurityUtil.currentUserId(users);
            log.info("Retrieved ownerId from SecurityUtil: {}", ownerId);
        } catch (Exception e) {
            log.error("Error getting current user ID: {}", e.getMessage(), e);
            throw new RuntimeException("Cannot get current user ID: " + e.getMessage(), e);
        }

        if (ownerId == null) {
            log.error("ownerId is NULL! This will cause constraint violation.");
            throw new RuntimeException("Owner ID is null - user not authenticated?");
        }

        log.info("Building merchant with ownerId={}, name={}, description={}", ownerId, req.name(), req.description());
        var m = Merchant.builder()
                .ownerUserId(ownerId)
                .name(req.name())
                .description(req.description())
                .build();

        log.info("Saving merchant to database...");
        m = merchantRepository.save(m);
        log.info("Merchant saved successfully with ID: {}", m.getId());

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

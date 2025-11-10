package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.SocialDtos.ShareRequest;
import kg.bishkek.fucent.fusent.dto.SocialDtos.ShareResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface ShareService {
    ShareResponse sharePost(ShareRequest request);

    void unsharePost(UUID postId);

    boolean isPostShared(UUID postId);

    Long getSharesCount(UUID postId);

    Page<ShareResponse> getPostShares(UUID postId, Pageable pageable);
}

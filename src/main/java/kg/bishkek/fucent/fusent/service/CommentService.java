package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.SocialDtos.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface CommentService {
    CommentResponse createComment(CreateCommentRequest request);

    void deleteComment(UUID commentId);

    Page<CommentResponse> getCommentsByPost(UUID postId, Pageable pageable);

    void flagComment(UUID commentId);
}

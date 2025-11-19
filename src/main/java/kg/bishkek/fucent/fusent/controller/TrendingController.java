package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kg.bishkek.fucent.fusent.model.Post;
import kg.bishkek.fucent.fusent.service.TrendingService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/trending")
@RequiredArgsConstructor
@Tag(name = "Trending", description = "Trending posts and recommendations")
public class TrendingController {

    private final TrendingService trendingService;

    @GetMapping("/posts")
    @Operation(summary = "Get trending posts", description = "Get posts sorted by trending score")
    public ResponseEntity<Page<Post>> getTrendingPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Post> trendingPosts = trendingService.getTrendingPosts(pageable);
        return ResponseEntity.ok(trendingPosts);
    }

    @GetMapping("/posts/24h")
    @Operation(summary = "Get trending posts (last 24 hours)", description = "Get trending posts from the last 24 hours")
    public ResponseEntity<Page<Post>> getTrending24Hours(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Post> trendingPosts = trendingService.getTrendingPostsWithinTimeWindow(24, pageable);
        return ResponseEntity.ok(trendingPosts);
    }

    @GetMapping("/posts/week")
    @Operation(summary = "Get trending posts (last week)", description = "Get trending posts from the last 7 days")
    public ResponseEntity<Page<Post>> getTrendingWeek(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Post> trendingPosts = trendingService.getTrendingPostsWithinTimeWindow(168, pageable); // 7 * 24 = 168 hours
        return ResponseEntity.ok(trendingPosts);
    }

    @GetMapping("/posts/custom")
    @Operation(summary = "Get trending posts (custom time window)", description = "Get trending posts within custom hours")
    public ResponseEntity<Page<Post>> getTrendingCustom(
            @RequestParam int hoursAgo,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Post> trendingPosts = trendingService.getTrendingPostsWithinTimeWindow(hoursAgo, pageable);
        return ResponseEntity.ok(trendingPosts);
    }

    @PostMapping("/posts/{postId}/view")
    @Operation(summary = "Increment view count", description = "Record a view for a post and update trending score")
    public ResponseEntity<Void> incrementViewCount(@PathVariable UUID postId) {
        trendingService.incrementViewCount(postId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/update-scores")
    @Operation(summary = "Update all trending scores", description = "Manually trigger trending score recalculation for all posts")
    public ResponseEntity<String> updateAllScores() {
        trendingService.updateAllTrendingScores();
        return ResponseEntity.ok("Trending scores update initiated");
    }

    @PostMapping("/posts/{postId}/update-score")
    @Operation(summary = "Update trending score for a post", description = "Recalculate trending score for a specific post")
    public ResponseEntity<Void> updatePostScore(@PathVariable UUID postId) {
        trendingService.updateTrendingScore(postId);
        return ResponseEntity.ok().build();
    }
}

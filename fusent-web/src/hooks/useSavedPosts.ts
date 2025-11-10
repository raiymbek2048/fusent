import { useMutation, useQuery, useQueryClient, UseMutationResult, UseQueryResult } from '@tanstack/react-query';
import api from '@/lib/api';
import { Post } from '@/types';

export interface SavedPostRequest {
  postId: string;
}

export interface SavedPostResponse {
  id: string;
  userId: string;
  postId: string;
  post: Post;
  createdAt: string;
}

export interface SavedPostsPage {
  content: SavedPostResponse[];
  totalPages: number;
  totalElements: number;
  size: number;
  number: number;
}

/**
 * Hook to save a post
 */
export function useSavePost(): UseMutationResult<SavedPostResponse, Error, string> {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (postId: string) => {
      const { data } = await api.post<SavedPostResponse>('/social/saved-posts', { postId });
      return data;
    },
    onSuccess: () => {
      // Invalidate saved posts queries to refetch
      queryClient.invalidateQueries({ queryKey: ['saved-posts'] });
    },
  });
}

/**
 * Hook to unsave a post
 */
export function useUnsavePost(): UseMutationResult<void, Error, string> {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (postId: string) => {
      await api.delete(`/social/saved-posts/${postId}`);
    },
    onSuccess: () => {
      // Invalidate saved posts queries to refetch
      queryClient.invalidateQueries({ queryKey: ['saved-posts'] });
    },
  });
}

/**
 * Hook to check if a post is saved
 */
export function useIsPostSaved(postId: string | undefined): UseQueryResult<boolean, Error> {
  return useQuery({
    queryKey: ['saved-posts', postId, 'is-saved'],
    queryFn: async () => {
      if (!postId) return false;
      const { data } = await api.get<boolean>(`/social/saved-posts/${postId}/is-saved`);
      return data;
    },
    enabled: !!postId,
  });
}

/**
 * Hook to get all saved posts with pagination
 */
export function useSavedPosts(page = 0, size = 20): UseQueryResult<SavedPostsPage, Error> {
  return useQuery({
    queryKey: ['saved-posts', page, size],
    queryFn: async () => {
      const { data } = await api.get<SavedPostsPage>('/social/saved-posts', {
        params: { page, size },
      });
      return data;
    },
  });
}

/**
 * Combined hook for toggling saved state of a post
 */
export function useToggleSavePost() {
  const savePost = useSavePost();
  const unsavePost = useUnsavePost();
  const queryClient = useQueryClient();

  const toggleSave = async (postId: string, isSaved: boolean) => {
    if (isSaved) {
      await unsavePost.mutateAsync(postId);
    } else {
      await savePost.mutateAsync(postId);
    }
    // Invalidate the is-saved query for this specific post
    queryClient.invalidateQueries({ queryKey: ['saved-posts', postId, 'is-saved'] });
  };

  return {
    toggleSave,
    isPending: savePost.isPending || unsavePost.isPending,
    error: savePost.error || unsavePost.error,
  };
}

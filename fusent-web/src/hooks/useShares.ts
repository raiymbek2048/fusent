import { useMutation, useQuery, useQueryClient, UseMutationResult, UseQueryResult } from '@tanstack/react-query';
import api from '@/lib/api';

export interface ShareRequest {
  postId: string;
}

export interface ShareResponse {
  id: string;
  userId: string;
  userName: string;
  userAvatarUrl?: string;
  postId: string;
  createdAt: string;
}

export interface SharesPage {
  content: ShareResponse[];
  totalPages: number;
  totalElements: number;
  size: number;
  number: number;
}

/**
 * Hook to share a post
 */
export function useSharePost(): UseMutationResult<ShareResponse, Error, string> {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (postId: string) => {
      const { data } = await api.post<ShareResponse>('/social/shares', { postId });
      return data;
    },
    onSuccess: (_, postId) => {
      // Invalidate shares queries to refetch
      queryClient.invalidateQueries({ queryKey: ['shares'] });
      queryClient.invalidateQueries({ queryKey: ['shares', postId] });
      queryClient.invalidateQueries({ queryKey: ['posts'] }); // Update post shares count
    },
  });
}

/**
 * Hook to unshare a post
 */
export function useUnsharePost(): UseMutationResult<void, Error, string> {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (postId: string) => {
      await api.delete(`/social/shares/${postId}`);
    },
    onSuccess: (_, postId) => {
      // Invalidate shares queries to refetch
      queryClient.invalidateQueries({ queryKey: ['shares'] });
      queryClient.invalidateQueries({ queryKey: ['shares', postId] });
      queryClient.invalidateQueries({ queryKey: ['posts'] }); // Update post shares count
    },
  });
}

/**
 * Hook to check if a post is shared by current user
 */
export function useIsPostShared(postId: string | undefined): UseQueryResult<boolean, Error> {
  return useQuery({
    queryKey: ['shares', postId, 'is-shared'],
    queryFn: async () => {
      if (!postId) return false;
      const { data } = await api.get<boolean>(`/social/shares/${postId}/is-shared`);
      return data;
    },
    enabled: !!postId,
  });
}

/**
 * Hook to get share count for a post
 */
export function useSharesCount(postId: string | undefined): UseQueryResult<number, Error> {
  return useQuery({
    queryKey: ['shares', postId, 'count'],
    queryFn: async () => {
      if (!postId) return 0;
      const { data } = await api.get<number>(`/social/shares/${postId}/shares/count`);
      return data;
    },
    enabled: !!postId,
  });
}

/**
 * Hook to get list of users who shared a post
 */
export function usePostShares(postId: string | undefined, page = 0, size = 20): UseQueryResult<SharesPage, Error> {
  return useQuery({
    queryKey: ['shares', postId, 'shares', page, size],
    queryFn: async () => {
      if (!postId) throw new Error('Post ID is required');
      const { data } = await api.get<SharesPage>(`/social/shares/${postId}/shares`, {
        params: { page, size },
      });
      return data;
    },
    enabled: !!postId,
  });
}

/**
 * Combined hook for toggling share state of a post
 */
export function useToggleSharePost() {
  const sharePost = useSharePost();
  const unsharePost = useUnsharePost();

  const toggleShare = async (postId: string, isShared: boolean) => {
    if (isShared) {
      await unsharePost.mutateAsync(postId);
    } else {
      await sharePost.mutateAsync(postId);
    }
  };

  return {
    toggleShare,
    isPending: sharePost.isPending || unsharePost.isPending,
    error: sharePost.error || unsharePost.error,
  };
}

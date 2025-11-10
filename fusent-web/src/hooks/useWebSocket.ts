import { useEffect, useRef, useCallback } from 'react';
import wsClient from '@/lib/websocket';

/**
 * React hook for WebSocket communication
 */
export function useWebSocket() {
  const isConnectedRef = useRef(false);

  useEffect(() => {
    // Connect on mount if not already connected
    if (!wsClient.isConnected() && !isConnectedRef.current) {
      const token = localStorage.getItem('token');
      wsClient.connect(token || undefined);
      isConnectedRef.current = true;
    }

    // Cleanup on unmount
    return () => {
      // Don't disconnect here as other components might be using it
      // wsClient.disconnect();
    };
  }, []);

  const send = useCallback((type: string, payload: any) => {
    wsClient.send(type, payload);
  }, []);

  const subscribe = useCallback((type: string, handler: (message: any) => void) => {
    wsClient.on(type, handler);

    // Return cleanup function
    return () => {
      wsClient.off(type, handler);
    };
  }, []);

  return {
    send,
    subscribe,
    isConnected: wsClient.isConnected(),
  };
}

/**
 * Hook specifically for chat WebSocket functionality
 */
export function useChatWebSocket() {
  const { send, subscribe } = useWebSocket();

  const sendMessage = useCallback((recipientId: string, messageText: string) => {
    send('/app/chat.sendMessage', {
      recipientId,
      messageText,
    });
  }, [send]);

  const sendTypingIndicator = useCallback((conversationId: string, recipientId: string, isTyping: boolean) => {
    send('/app/chat.typing', {
      conversationId,
      recipientId,
      isTyping,
    });
  }, [send]);

  const markAsRead = useCallback((messageId: string) => {
    send('/app/chat.markRead', {
      messageId,
    });
  }, [send]);

  const subscribeToMessages = useCallback((handler: (message: any) => void) => {
    return subscribe('/user/queue/messages', handler);
  }, [subscribe]);

  const subscribeToTyping = useCallback((handler: (data: any) => void) => {
    return subscribe('/user/queue/typing', handler);
  }, [subscribe]);

  const subscribeToReadReceipts = useCallback((handler: (data: any) => void) => {
    return subscribe('/user/queue/read-receipts', handler);
  }, [subscribe]);

  const subscribeToErrors = useCallback((handler: (error: any) => void) => {
    return subscribe('/user/queue/errors', handler);
  }, [subscribe]);

  return {
    sendMessage,
    sendTypingIndicator,
    markAsRead,
    subscribeToMessages,
    subscribeToTyping,
    subscribeToReadReceipts,
    subscribeToErrors,
  };
}

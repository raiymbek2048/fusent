'use client'

import { useState, useEffect, useRef, Suspense } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { Send, MessageCircle } from 'lucide-react'
import { useConversations, useMessages, useSendMessage, useCreateConversation } from '@/hooks/useChat'
import { useAuthStore } from '@/store/authStore'
import { Button, Card, CardContent, Input, LoadingScreen } from '@/components/ui'
import MainLayout from '@/components/MainLayout'

export const dynamic = 'force-dynamic'

function ChatPageContent() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const sellerId = searchParams.get('sellerId')

  const user = useAuthStore((state) => state.user)
  const [selectedConversationId, setSelectedConversationId] = useState<string | null>(null)
  const [messageText, setMessageText] = useState('')
  const messagesEndRef = useRef<HTMLDivElement>(null)

  const { data: conversations, isLoading: conversationsLoading } = useConversations(user?.id)
  const { data: messages, isLoading: messagesLoading } = useMessages(selectedConversationId || undefined)
  const sendMessage = useSendMessage()
  const createConversation = useCreateConversation()

  // Auto-create conversation if sellerId is provided
  useEffect(() => {
    if (sellerId && !conversationsLoading && user) {
      createConversation.mutate(sellerId, {
        onSuccess: (conv) => {
          setSelectedConversationId(conv.id)
        },
      })
    }
  }, [sellerId, conversationsLoading])

  // Auto-scroll to bottom when new messages arrive
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  if (!user) {
    router.push('/login')
    return null
  }

  if (conversationsLoading) {
    return <LoadingScreen message="Загрузка чатов..." />
  }

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!messageText.trim() || !selectedConversationId) return

    sendMessage.mutate(
      {
        conversationId: selectedConversationId,
        content: messageText,
      },
      {
        onSuccess: () => {
          setMessageText('')
        },
      }
    )
  }

  const selectedConversation = conversations?.find(c => c.id === selectedConversationId)

  return (
    <MainLayout>
      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 h-[calc(100vh-200px)]">
          {/* Conversations List */}
          <Card className="md:col-span-1 overflow-hidden flex flex-col">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-xl font-semibold">Сообщения</h2>
            </div>
            <div className="flex-grow overflow-y-auto">
              {conversations && conversations.length > 0 ? (
                <div className="divide-y divide-gray-200">
                  {conversations.map((conv) => {
                    const otherUser = user.role === 'BUYER' ? conv.seller : conv.buyer
                    return (
                      <button
                        key={conv.id}
                        onClick={() => setSelectedConversationId(conv.id)}
                        className={`w-full px-6 py-4 text-left hover:bg-gray-50 transition-colors ${
                          selectedConversationId === conv.id ? 'bg-blue-50' : ''
                        }`}
                      >
                        <div className="flex items-center justify-between mb-1">
                          <p className="font-medium text-gray-900">
                            {otherUser?.email || 'Пользователь'}
                          </p>
                          {conv.unreadCount > 0 && (
                            <span className="bg-blue-600 text-white text-xs px-2 py-1 rounded-full">
                              {conv.unreadCount}
                            </span>
                          )}
                        </div>
                        <p className="text-sm text-gray-500">
                          {new Date(conv.lastMessageAt).toLocaleDateString('ru-RU')}
                        </p>
                      </button>
                    )
                  })}
                </div>
              ) : (
                <div className="flex flex-col items-center justify-center h-full text-center p-6">
                  <MessageCircle className="w-16 h-16 text-gray-300 mb-4" />
                  <p className="text-gray-600">Нет активных чатов</p>
                </div>
              )}
            </div>
          </Card>

          {/* Messages */}
          <Card className="md:col-span-2 overflow-hidden flex flex-col">
            {selectedConversation ? (
              <>
                {/* Chat Header */}
                <div className="px-6 py-4 border-b border-gray-200">
                  <h3 className="font-semibold text-gray-900">
                    {user.role === 'BUYER'
                      ? selectedConversation.seller?.email
                      : selectedConversation.buyer?.email}
                  </h3>
                </div>

                {/* Messages List */}
                <div className="flex-grow overflow-y-auto p-6 space-y-4 bg-gray-50">
                  {messagesLoading ? (
                    <div className="flex items-center justify-center h-full">
                      <div className="text-gray-500">Загрузка сообщений...</div>
                    </div>
                  ) : messages && messages.content.length > 0 ? (
                    <>
                      {messages.content.map((message) => {
                        const isOwnMessage = message.senderId === user.id
                        return (
                          <div
                            key={message.id}
                            className={`flex ${isOwnMessage ? 'justify-end' : 'justify-start'}`}
                          >
                            <div
                              className={`max-w-xs md:max-w-md px-4 py-2 rounded-lg ${
                                isOwnMessage
                                  ? 'bg-blue-600 text-white'
                                  : 'bg-white text-gray-900 border border-gray-200'
                              }`}
                            >
                              <p className="whitespace-pre-wrap">{message.content}</p>
                              <p
                                className={`text-xs mt-1 ${
                                  isOwnMessage ? 'text-blue-100' : 'text-gray-500'
                                }`}
                              >
                                {new Date(message.createdAt).toLocaleTimeString('ru-RU', {
                                  hour: '2-digit',
                                  minute: '2-digit',
                                })}
                              </p>
                            </div>
                          </div>
                        )
                      })}
                      <div ref={messagesEndRef} />
                    </>
                  ) : (
                    <div className="flex items-center justify-center h-full">
                      <p className="text-gray-500">Начните диалог</p>
                    </div>
                  )}
                </div>

                {/* Message Input */}
                <form onSubmit={handleSendMessage} className="px-6 py-4 border-t border-gray-200 bg-white">
                  <div className="flex gap-2">
                    <Input
                      value={messageText}
                      onChange={(e) => setMessageText(e.target.value)}
                      placeholder="Введите сообщение..."
                      className="flex-grow"
                      disabled={sendMessage.isPending}
                    />
                    <Button
                      type="submit"
                      disabled={!messageText.trim() || sendMessage.isPending}
                      isLoading={sendMessage.isPending}
                    >
                      <Send className="w-5 h-5" />
                    </Button>
                  </div>
                </form>
              </>
            ) : (
              <div className="flex flex-col items-center justify-center h-full text-center">
                <MessageCircle className="w-24 h-24 text-gray-300 mb-4" />
                <p className="text-gray-600">Выберите чат, чтобы начать общение</p>
              </div>
            )}
          </Card>
        </div>
      </div>
    </MainLayout>
  )
}

export default function ChatPage() {
  return (
    <Suspense fallback={<LoadingScreen message="Загрузка чатов..." />}>
      <ChatPageContent />
    </Suspense>
  )
}

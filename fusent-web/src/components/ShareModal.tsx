'use client'

import { useState } from 'react'
import { X, Search, Send, Check } from 'lucide-react'
import { useCreateConversation } from '@/hooks/useChat'
import { useAuthStore } from '@/store/authStore'
import { Input, Button } from './ui'

interface ShareModalProps {
  isOpen: boolean
  onClose: () => void
  shareUrl: string
  shareType: 'product' | 'post'
  title?: string
}

export default function ShareModal({
  isOpen,
  onClose,
  shareUrl,
  shareType,
  title,
}: ShareModalProps) {
  const { user } = useAuthStore()
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedUsers, setSelectedUsers] = useState<string[]>([])
  const [sentTo, setSentTo] = useState<string[]>([])
  const createConversation = useCreateConversation(user?.id)

  // Mock users/shops data - replace with real API call
  const mockUsers = [
    { id: '1', name: 'Магазин 1', type: 'shop' },
    { id: '2', name: 'Магазин 2', type: 'shop' },
    { id: '3', name: 'Пользователь 1', type: 'user' },
    { id: '4', name: 'Пользователь 2', type: 'user' },
  ]

  const filteredUsers = mockUsers.filter((u) =>
    u.name.toLowerCase().includes(searchQuery.toLowerCase())
  )

  const handleToggleUser = (userId: string) => {
    setSelectedUsers((prev) =>
      prev.includes(userId)
        ? prev.filter((id) => id !== userId)
        : [...prev, userId]
    )
  }

  const handleSend = async () => {
    // In real implementation, this would send messages via API
    // For now, just mark as sent
    setSentTo([...selectedUsers])

    // Reset after a delay
    setTimeout(() => {
      setSelectedUsers([])
      setSentTo([])
      onClose()
    }, 1500)
  }

  if (!isOpen) return null

  return (
    <>
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black/50 z-50 transition-opacity"
        onClick={onClose}
      />

      {/* Modal - Instagram-style bottom sheet */}
      <div className="fixed inset-x-0 bottom-0 z-50 bg-white rounded-t-3xl shadow-2xl max-h-[70vh] flex flex-col animate-slide-up">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900">
            Поделиться {shareType === 'product' ? 'товаром' : 'публикацией'}
          </h3>
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-full transition-colors"
          >
            <X className="w-5 h-5 text-gray-600" />
          </button>
        </div>

        {/* Search */}
        <div className="px-6 py-3 border-b border-gray-200">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <Input
              type="text"
              placeholder="Поиск пользователей и магазинов..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10"
            />
          </div>
        </div>

        {/* Title (if provided) */}
        {title && (
          <div className="px-6 py-3 border-b border-gray-200 bg-gray-50">
            <p className="text-sm text-gray-700 truncate">{title}</p>
          </div>
        )}

        {/* Users/Shops List */}
        <div className="flex-1 overflow-y-auto">
          <div className="divide-y divide-gray-200">
            {filteredUsers.map((u) => {
              const isSelected = selectedUsers.includes(u.id)
              const isSent = sentTo.includes(u.id)

              return (
                <button
                  key={u.id}
                  onClick={() => !isSent && handleToggleUser(u.id)}
                  disabled={isSent}
                  className={`w-full px-6 py-4 flex items-center justify-between hover:bg-gray-50 transition-colors ${
                    isSent ? 'bg-green-50' : ''
                  }`}
                >
                  <div className="flex items-center space-x-3">
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center text-white font-bold">
                      {u.name.charAt(0).toUpperCase()}
                    </div>
                    <div className="text-left">
                      <p className="font-medium text-gray-900">{u.name}</p>
                      <p className="text-xs text-gray-500">
                        {u.type === 'shop' ? 'Магазин' : 'Пользователь'}
                      </p>
                    </div>
                  </div>
                  <div>
                    {isSent ? (
                      <div className="w-6 h-6 rounded-full bg-green-500 flex items-center justify-center">
                        <Check className="w-4 h-4 text-white" />
                      </div>
                    ) : (
                      <div
                        className={`w-6 h-6 rounded-full border-2 transition-colors ${
                          isSelected
                            ? 'bg-blue-600 border-blue-600'
                            : 'border-gray-300'
                        }`}
                      >
                        {isSelected && (
                          <Check className="w-full h-full text-white p-0.5" />
                        )}
                      </div>
                    )}
                  </div>
                </button>
              )
            })}
          </div>

          {filteredUsers.length === 0 && (
            <div className="flex flex-col items-center justify-center h-full py-12 text-center">
              <Search className="w-16 h-16 text-gray-300 mb-4" />
              <p className="text-gray-600">Пользователи не найдены</p>
              <p className="text-sm text-gray-500 mt-1">
                Попробуйте изменить поисковый запрос
              </p>
            </div>
          )}
        </div>

        {/* Send Button */}
        {selectedUsers.length > 0 && (
          <div className="px-6 py-4 border-t border-gray-200 bg-white">
            <Button
              onClick={handleSend}
              className="w-full flex items-center justify-center space-x-2"
            >
              <Send className="w-5 h-5" />
              <span>
                Отправить ({selectedUsers.length})
              </span>
            </Button>
          </div>
        )}
      </div>

      <style jsx global>{`
        @keyframes slide-up {
          from {
            transform: translateY(100%);
          }
          to {
            transform: translateY(0);
          }
        }
        .animate-slide-up {
          animation: slide-up 0.3s ease-out;
        }
      `}</style>
    </>
  )
}

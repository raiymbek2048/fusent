'use client'

import { useState } from 'react'
import { usePostShares } from '@/hooks/useShares'
import Modal from '@/components/ui/Modal'
import { Share2, X, User as UserIcon } from 'lucide-react'
import Spinner from '@/components/ui/Spinner'
import Link from 'next/link'

interface SharesModalProps {
  postId: string
  isOpen: boolean
  onClose: () => void
}

export default function SharesModal({ postId, isOpen, onClose }: SharesModalProps) {
  const [page] = useState(0)
  const { data, isLoading, error } = usePostShares(postId, page, 50)

  const shares = data?.content || []

  return (
    <Modal isOpen={isOpen} onClose={onClose}>
      <div className="bg-white rounded-lg shadow-xl max-w-md w-full max-h-[80vh] overflow-hidden flex flex-col">
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <Share2 className="h-5 w-5 text-green-500" />
            <h2 className="text-lg font-semibold text-gray-900">Поделились</h2>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto">
          {isLoading ? (
            <div className="flex items-center justify-center py-12">
              <Spinner />
            </div>
          ) : error ? (
            <div className="text-center py-12 px-6">
              <p className="text-red-500 mb-4">Ошибка при загрузке</p>
              <button
                onClick={() => window.location.reload()}
                className="px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600"
              >
                Повторить
              </button>
            </div>
          ) : shares.length === 0 ? (
            <div className="text-center py-12 px-6">
              <Share2 className="h-12 w-12 text-gray-300 mx-auto mb-3" />
              <p className="text-gray-500">Никто еще не поделился этим постом</p>
            </div>
          ) : (
            <div className="divide-y divide-gray-100">
              {shares.map((share) => (
                <Link
                  key={share.id}
                  href={`/users/${share.userId}`}
                  onClick={onClose}
                  className="flex items-center space-x-3 px-6 py-4 hover:bg-gray-50 transition-colors"
                >
                  {/* Avatar */}
                  <div className="flex-shrink-0">
                    {share.userAvatarUrl ? (
                      <img
                        src={share.userAvatarUrl}
                        alt={share.userName}
                        className="w-10 h-10 rounded-full object-cover"
                      />
                    ) : (
                      <div className="w-10 h-10 rounded-full bg-primary-100 flex items-center justify-center">
                        <UserIcon className="h-5 w-5 text-primary-500" />
                      </div>
                    )}
                  </div>

                  {/* User Info */}
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-semibold text-gray-900 truncate">
                      {share.userName}
                    </p>
                    <p className="text-xs text-gray-500">
                      {new Date(share.createdAt).toLocaleDateString('ru-RU', {
                        day: 'numeric',
                        month: 'long',
                        year: 'numeric',
                      })}
                    </p>
                  </div>

                  {/* Share Icon */}
                  <Share2 className="h-4 w-4 text-green-500" />
                </Link>
              ))}
            </div>
          )}
        </div>

        {/* Footer - Show total count */}
        {shares.length > 0 && (
          <div className="px-6 py-3 border-t border-gray-200 bg-gray-50">
            <p className="text-sm text-gray-600 text-center">
              Всего: {data?.totalElements || shares.length}
            </p>
          </div>
        )}
      </div>
    </Modal>
  )
}

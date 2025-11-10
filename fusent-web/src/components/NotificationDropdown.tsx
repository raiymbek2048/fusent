'use client'

import { useState, useRef, useEffect } from 'react'
import { Bell, Check, X, Package, MessageCircle, ShoppingCart, AlertCircle, CheckCheck } from 'lucide-react'
import { useNotificationHistory, useUnreadNotificationsCount, useMarkAllAsRead } from '@/hooks/useNotifications'
import { formatDistanceToNow } from 'date-fns'
import { ru } from 'date-fns/locale'

interface NotificationDropdownProps {
  userEmail?: string
}

export default function NotificationDropdown({ userEmail }: NotificationDropdownProps) {
  const [isOpen, setIsOpen] = useState(false)
  const dropdownRef = useRef<HTMLDivElement>(null)

  const { data: notifications = [] } = useNotificationHistory(userEmail)
  const { data: unreadCount = 0 } = useUnreadNotificationsCount(userEmail)
  const markAllAsRead = useMarkAllAsRead(userEmail)

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false)
      }
    }

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside)
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [isOpen])

  const getNotificationIcon = (templateKey: string) => {
    if (templateKey.includes('order')) {
      return <Package className="h-5 w-5 text-blue-600" />
    } else if (templateKey.includes('message') || templateKey.includes('chat')) {
      return <MessageCircle className="h-5 w-5 text-green-600" />
    } else if (templateKey.includes('cart')) {
      return <ShoppingCart className="h-5 w-5 text-purple-600" />
    }
    return <AlertCircle className="h-5 w-5 text-gray-600" />
  }

  const getNotificationTitle = (templateKey: string, payload: any) => {
    switch (templateKey) {
      case 'order.created':
        return 'Новый заказ'
      case 'order.paid':
        return 'Заказ оплачен'
      case 'order.shipped':
        return 'Заказ отправлен'
      case 'order.delivered':
        return 'Заказ доставлен'
      case 'message.new':
        return 'Новое сообщение'
      case 'cart.abandoned':
        return 'Товары в корзине'
      default:
        return 'Уведомление'
    }
  }

  const getNotificationMessage = (templateKey: string, payload: any) => {
    switch (templateKey) {
      case 'order.created':
        return `Ваш заказ #${payload?.orderId?.slice(0, 8) || 'XXX'} создан`
      case 'order.paid':
        return `Заказ #${payload?.orderId?.slice(0, 8) || 'XXX'} успешно оплачен`
      case 'order.shipped':
        return `Заказ #${payload?.orderId?.slice(0, 8) || 'XXX'} отправлен`
      case 'order.delivered':
        return `Заказ #${payload?.orderId?.slice(0, 8) || 'XXX'} доставлен`
      case 'message.new':
        return payload?.message || 'У вас новое сообщение'
      case 'cart.abandoned':
        return `В вашей корзине ${payload?.itemCount || 0} товаров`
      default:
        return 'У вас новое уведомление'
    }
  }

  const inAppNotifications = notifications.filter(n => n.channel === 'IN_APP')

  return (
    <div className="relative" ref={dropdownRef}>
      {/* Bell Icon */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="relative text-gray-700 hover:text-blue-600 transition-colors"
        title="Уведомления"
      >
        <Bell className="h-6 w-6" />
        {unreadCount > 0 && (
          <span className="absolute -top-2 -right-2 bg-red-600 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center">
            {unreadCount > 9 ? '9+' : unreadCount}
          </span>
        )}
      </button>

      {/* Dropdown */}
      {isOpen && (
        <div className="absolute right-0 mt-2 w-80 sm:w-96 bg-white rounded-lg shadow-xl border border-gray-200 z-50">
          {/* Header */}
          <div className="px-4 py-3 border-b border-gray-200 flex items-center justify-between">
            <h3 className="text-lg font-semibold text-gray-900">Уведомления</h3>
            <button
              onClick={() => setIsOpen(false)}
              className="text-gray-400 hover:text-gray-600"
            >
              <X className="h-5 w-5" />
            </button>
          </div>

          {/* Notifications List */}
          <div className="max-h-96 overflow-y-auto">
            {inAppNotifications.length === 0 ? (
              <div className="px-4 py-8 text-center text-gray-500">
                <Bell className="h-12 w-12 mx-auto mb-3 text-gray-300" />
                <p>Нет уведомлений</p>
              </div>
            ) : (
              <div className="divide-y divide-gray-100">
                {inAppNotifications.map((notification) => (
                  <div
                    key={notification.id}
                    className={`px-4 py-3 hover:bg-gray-50 transition-colors cursor-pointer ${
                      notification.status === 'QUEUED' ? 'bg-blue-50' : ''
                    }`}
                  >
                    <div className="flex gap-3">
                      {/* Icon */}
                      <div className="flex-shrink-0 mt-1">
                        {getNotificationIcon(notification.templateKey)}
                      </div>

                      {/* Content */}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-start justify-between gap-2">
                          <p className="text-sm font-semibold text-gray-900">
                            {getNotificationTitle(notification.templateKey, notification.payloadJson)}
                          </p>
                          {notification.status === 'QUEUED' && (
                            <div className="w-2 h-2 bg-blue-600 rounded-full flex-shrink-0 mt-1.5" />
                          )}
                        </div>
                        <p className="text-sm text-gray-600 mt-0.5">
                          {getNotificationMessage(notification.templateKey, notification.payloadJson)}
                        </p>
                        <p className="text-xs text-gray-400 mt-1">
                          {formatDistanceToNow(new Date(notification.createdAt), {
                            addSuffix: true,
                            locale: ru,
                          })}
                        </p>
                      </div>

                      {/* Status */}
                      {notification.status === 'DELIVERED' && (
                        <div className="flex-shrink-0">
                          <Check className="h-4 w-4 text-green-500" />
                        </div>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Footer */}
          {inAppNotifications.length > 0 && unreadCount > 0 && (
            <div className="px-4 py-3 border-t border-gray-200">
              <button
                onClick={() => {
                  markAllAsRead.mutate()
                }}
                disabled={markAllAsRead.isPending}
                className="flex items-center gap-2 text-sm text-blue-600 hover:text-blue-700 font-medium disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <CheckCheck className="h-4 w-4" />
                {markAllAsRead.isPending ? 'Отмечаем...' : 'Отметить все как прочитанные'}
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  )
}

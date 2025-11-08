'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import MainLayout from '@/components/MainLayout'
import { useAuth } from '@/hooks/useAuth'
import { useCreateShop } from '@/hooks/useShops'
import { useCreatePost } from '@/hooks/usePosts'
import { Plus, Store, Image as ImageIcon } from 'lucide-react'
import toast from 'react-hot-toast'

export default function SellerDashboard() {
  const router = useRouter()
  const { user } = useAuth()
  const { mutate: createShop, isPending: isCreatingShop } = useCreateShop()
  const { mutate: createPost, isPending: isCreatingPost } = useCreatePost()

  // Check if user is a seller
  if (user && user.role !== 'SELLER') {
    router.push('/')
    return null
  }

  const [showShopForm, setShowShopForm] = useState(false)
  const [showPostForm, setShowPostForm] = useState(false)
  
  const [shopForm, setShopForm] = useState({
    name: '',
    description: '',
    address: '',
    phone: '',
  })

  const [postForm, setPostForm] = useState({
    text: '',
    postType: 'PHOTO' as const,
    visibility: 'PUBLIC' as const,
  })

  const handleCreateShop = (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!shopForm.name.trim()) {
      toast.error('Введите название магазина')
      return
    }

    createShop(shopForm, {
      onSuccess: () => {
        setShowShopForm(false)
        setShopForm({ name: '', description: '', address: '', phone: '' })
      },
    })
  }

  const handleCreatePost = (e: React.FormEvent) => {
    e.preventDefault()

    if (!user) {
      toast.error('Необходима авторизация')
      return
    }

    if (!postForm.text.trim()) {
      toast.error('Введите текст публикации')
      return
    }

    createPost({
      ownerType: 'USER',
      ownerId: user.id,
      text: postForm.text,
      postType: postForm.postType,
      visibility: postForm.visibility,
    }, {
      onSuccess: () => {
        setShowPostForm(false)
        setPostForm({ text: '', postType: 'PHOTO', visibility: 'PUBLIC' })
      },
    })
  }

  return (
    <MainLayout>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Панель продавца</h1>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          {/* Create Shop Card */}
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center">
                <Store className="h-6 w-6 text-blue-600 mr-2" />
                <h2 className="text-xl font-semibold">Мои магазины</h2>
              </div>
              <button
                onClick={() => setShowShopForm(!showShopForm)}
                className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center"
              >
                <Plus className="h-5 w-5 mr-1" />
                Создать
              </button>
            </div>
            
            {showShopForm && (
              <form onSubmit={handleCreateShop} className="space-y-4 mt-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Название магазина *
                  </label>
                  <input
                    type="text"
                    value={shopForm.name}
                    onChange={(e) => setShopForm({ ...shopForm, name: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    placeholder="Мой магазин"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Описание
                  </label>
                  <textarea
                    value={shopForm.description}
                    onChange={(e) => setShopForm({ ...shopForm, description: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    rows={3}
                    placeholder="Описание вашего магазина"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Адрес
                  </label>
                  <input
                    type="text"
                    value={shopForm.address}
                    onChange={(e) => setShopForm({ ...shopForm, address: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    placeholder="г. Бишкек, ул. ..."
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Телефон
                  </label>
                  <input
                    type="tel"
                    value={shopForm.phone}
                    onChange={(e) => setShopForm({ ...shopForm, phone: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    placeholder="+996 ..."
                  />
                </div>

                <div className="flex gap-2">
                  <button
                    type="submit"
                    disabled={isCreatingShop}
                    className="flex-1 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50"
                  >
                    {isCreatingShop ? 'Создание...' : 'Создать магазин'}
                  </button>
                  <button
                    type="button"
                    onClick={() => setShowShopForm(false)}
                    className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
                  >
                    Отмена
                  </button>
                </div>
              </form>
            )}
          </div>

          {/* Create Post Card */}
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center">
                <ImageIcon className="h-6 w-6 text-blue-600 mr-2" />
                <h2 className="text-xl font-semibold">Публикации</h2>
              </div>
              <button
                onClick={() => setShowPostForm(!showPostForm)}
                className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center"
              >
                <Plus className="h-5 w-5 mr-1" />
                Создать
              </button>
            </div>

            {showPostForm && (
              <form onSubmit={handleCreatePost} className="space-y-4 mt-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Текст публикации *
                  </label>
                  <textarea
                    value={postForm.text}
                    onChange={(e) => setPostForm({ ...postForm, text: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    rows={4}
                    placeholder="Что нового у вас сегодня?"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Видимость
                  </label>
                  <select
                    value={postForm.visibility}
                    onChange={(e) => setPostForm({ ...postForm, visibility: e.target.value as any })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                    <option value="PUBLIC">Публичная</option>
                    <option value="FOLLOWERS">Только подписчики</option>
                    <option value="PRIVATE">Приватная</option>
                  </select>
                </div>

                <div className="flex gap-2">
                  <button
                    type="submit"
                    disabled={isCreatingPost}
                    className="flex-1 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50"
                  >
                    {isCreatingPost ? 'Публикация...' : 'Опубликовать'}
                  </button>
                  <button
                    type="button"
                    onClick={() => setShowPostForm(false)}
                    className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
                  >
                    Отмена
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>

        {/* Quick Links */}
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold mb-4">Быстрые ссылки</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <a
              href="/shops"
              className="block p-4 border border-gray-200 rounded-lg hover:border-blue-500 hover:shadow transition-all"
            >
              <h3 className="font-medium text-gray-900">Мои магазины</h3>
              <p className="text-sm text-gray-500 mt-1">Управление магазинами</p>
            </a>
            <a
              href="/feed"
              className="block p-4 border border-gray-200 rounded-lg hover:border-blue-500 hover:shadow transition-all"
            >
              <h3 className="font-medium text-gray-900">Лента</h3>
              <p className="text-sm text-gray-500 mt-1">Просмотр публикаций</p>
            </a>
            <a
              href="/products"
              className="block p-4 border border-gray-200 rounded-lg hover:border-blue-500 hover:shadow transition-all"
            >
              <h3 className="font-medium text-gray-900">Товары</h3>
              <p className="text-sm text-gray-500 mt-1">Управление товарами</p>
            </a>
          </div>
        </div>
      </div>
    </MainLayout>
  )
}

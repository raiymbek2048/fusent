import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import { Cart, CartItem } from '@/types'

interface CartState {
  cart: Cart | null
  isLoading: boolean
  error: string | null
  setCart: (cart: Cart | null) => void
  setLoading: (isLoading: boolean) => void
  setError: (error: string | null) => void
  addItem: (item: CartItem) => void
  updateItem: (variantId: string, qty: number) => void
  removeItem: (variantId: string) => void
  clearCart: () => void
  getTotalItems: () => number
  getTotalAmount: () => number
}

export const useCartStore = create<CartState>()(
  persist(
    (set, get) => ({
      cart: null,
      isLoading: false,
      error: null,

      setCart: (cart) => set({ cart, error: null }),

      setLoading: (isLoading) => set({ isLoading }),

      setError: (error) => set({ error }),

      addItem: (item) =>
        set((state) => {
          if (!state.cart) return state

          const existingItemIndex = state.cart.items.findIndex(
            (i) => i.variantId === item.variantId
          )

          let newItems: CartItem[]
          if (existingItemIndex >= 0) {
            // Update existing item
            newItems = [...state.cart.items]
            newItems[existingItemIndex] = {
              ...newItems[existingItemIndex],
              qty: newItems[existingItemIndex].qty + item.qty,
              subtotal:
                (newItems[existingItemIndex].qty + item.qty) *
                newItems[existingItemIndex].price,
            }
          } else {
            // Add new item
            newItems = [...state.cart.items, item]
          }

          const totalItems = newItems.reduce((sum, i) => sum + i.qty, 0)
          const totalAmount = newItems.reduce((sum, i) => sum + i.subtotal, 0)

          return {
            cart: {
              ...state.cart,
              items: newItems,
              totalItems,
              totalAmount,
              updatedAt: new Date().toISOString(),
            },
          }
        }),

      updateItem: (variantId, qty) =>
        set((state) => {
          if (!state.cart) return state

          const newItems = state.cart.items
            .map((item) =>
              item.variantId === variantId
                ? { ...item, qty, subtotal: qty * item.price }
                : item
            )
            .filter((item) => item.qty > 0)

          const totalItems = newItems.reduce((sum, i) => sum + i.qty, 0)
          const totalAmount = newItems.reduce((sum, i) => sum + i.subtotal, 0)

          return {
            cart: {
              ...state.cart,
              items: newItems,
              totalItems,
              totalAmount,
              updatedAt: new Date().toISOString(),
            },
          }
        }),

      removeItem: (variantId) =>
        set((state) => {
          if (!state.cart) return state

          const newItems = state.cart.items.filter(
            (item) => item.variantId !== variantId
          )

          const totalItems = newItems.reduce((sum, i) => sum + i.qty, 0)
          const totalAmount = newItems.reduce((sum, i) => sum + i.subtotal, 0)

          return {
            cart: {
              ...state.cart,
              items: newItems,
              totalItems,
              totalAmount,
              updatedAt: new Date().toISOString(),
            },
          }
        }),

      clearCart: () =>
        set((state) => {
          if (!state.cart) return state

          return {
            cart: {
              ...state.cart,
              items: [],
              totalItems: 0,
              totalAmount: 0,
              updatedAt: new Date().toISOString(),
            },
          }
        }),

      getTotalItems: () => {
        const state = get()
        return state.cart?.totalItems ?? 0
      },

      getTotalAmount: () => {
        const state = get()
        return state.cart?.totalAmount ?? 0
      },
    }),
    {
      name: 'cart-storage',
      partialize: (state) => ({ cart: state.cart }),
    }
  )
)

// API Response Types
export interface ApiResponse<T> {
  data: T
  message?: string
  status: number
}

// User & Auth Types
export interface User {
  id: string
  email: string
  role: 'ADMIN' | 'SELLER' | 'BUYER'
  createdAt: string
  profile?: UserProfile
}

export interface UserProfile {
  id: string
  firstName: string
  lastName: string
  phone?: string
  avatarUrl?: string
}

export interface AuthResponse {
  accessToken: string
  refreshToken: string
  expiresIn: number
  user: User
}

export interface LoginRequest {
  email: string
  password: string
}

export interface RegisterRequest {
  email: string
  password: string
  role: 'SELLER' | 'BUYER'
  firstName?: string
  lastName?: string
}

export interface ChangePasswordRequest {
  oldPassword: string
  newPassword: string
}

// Shop Types
export interface Shop {
  id: string
  sellerId: string
  name: string
  description?: string
  logoUrl?: string
  bannerUrl?: string
  rating: number
  totalReviews: number
  totalProducts: number
  address?: string
  latitude?: number
  longitude?: number
  createdAt: string
}

export interface CreateShopRequest {
  name: string
  description?: string
  address?: string
  latitude?: number
  longitude?: number
}

// Product Types
export interface Product {
  id: string
  shopId: string
  categoryId: string
  name: string
  description?: string
  basePrice: number
  rating: number
  totalReviews: number
  totalSales: number
  createdAt: string
  images?: ProductImage[]
  variants?: ProductVariant[]
}

export interface ProductImage {
  id: string
  productId: string
  imageUrl: string
  displayOrder: number
}

export interface ProductVariant {
  id: string
  productId: string
  sku: string
  name: string
  price: number
  stockQuantity: number
  attributes: Record<string, string>
}

export interface CreateProductRequest {
  shopId: string
  categoryId: string
  name: string
  description?: string
  basePrice: number
}

// Category Types
export interface Category {
  id: string
  name: string
  slug: string
  description?: string
  parentId?: string
  iconUrl?: string
}

// Cart Types
export interface Cart {
  id: string
  userId: string
  items: CartItem[]
  totalItems: number
  totalAmount: number
  createdAt: string
  updatedAt: string
}

export interface CartItem {
  id: string
  variantId: string
  variantName: string
  productName: string
  productImage?: string
  shopId: string
  shopName: string
  price: number
  qty: number
  subtotal: number
  stockQty: number
  addedAt: string
}

export interface AddToCartRequest {
  variantId: string
  qty: number
}

export interface UpdateCartItemRequest {
  qty: number
}

export interface CartSummary {
  totalItems: number
  totalAmount: number
}

// Order Types
export interface Order {
  id: string
  userId: string
  shopId: string
  shopName: string
  status: 'pending' | 'paid' | 'cancelled' | 'fulfilled' | 'refunded'
  items: OrderItem[]
  totalAmount: number
  createdAt: string
  paidAt?: string
  fulfilledAt?: string
}

export interface OrderItem {
  id: string
  variantId: string
  variantName: string
  productName: string
  productImage?: string
  qty: number
  price: number
  subtotal: number
}

export interface OrderSummary {
  id: string
  shopId: string
  shopName: string
  status: string
  itemCount: number
  totalAmount: number
  createdAt: string
}

export interface CheckoutRequest {
  shopId: string
  shippingAddress?: string
  paymentMethod?: string
  notes?: string
}

// Social Types
export interface Post {
  id: string
  shopId: string
  content: string
  mediaUrls?: string[]
  likesCount: number
  commentsCount: number
  createdAt: string
  shop?: Shop
}

export interface Comment {
  id: string
  postId: string
  userId: string
  content: string
  isVerifiedPurchase: boolean
  createdAt: string
  user?: User
}

export interface CreatePostRequest {
  shopId: string
  content: string
  mediaUrls?: string[]
}

export interface CreateCommentRequest {
  postId: string
  content: string
}

// Chat Types
export interface Conversation {
  id: string
  buyerId: string
  sellerId: string
  lastMessageAt: string
  unreadCount: number
  buyer?: User
  seller?: User
}

export interface Message {
  id: string
  conversationId: string
  senderId: string
  content: string
  mediaUrl?: string
  isRead: boolean
  createdAt: string
}

export interface SendMessageRequest {
  conversationId: string
  content: string
  mediaUrl?: string
}

// Pagination Types
export interface PageRequest {
  page?: number
  size?: number
  sort?: string
}

export interface PageResponse<T> {
  content: T[]
  totalElements: number
  totalPages: number
  size: number
  number: number
  first: boolean
  last: boolean
}

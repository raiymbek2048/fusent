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
  merchantId?: string
  merchantName?: string
  sellerId?: string
  ownerId?: string
  name: string
  description?: string
  city?: string
  address?: string
  phone?: string
  logoUrl?: string
  bannerUrl?: string
  rating?: number
  totalReviews?: number
  totalProducts?: number
  lat?: number
  lon?: number
  geoLat?: number
  geoLon?: number
  openTime?: string
  closeTime?: string
  daysOfWeek?: string
  active?: boolean
  posStatus?: string
  lastHeartbeatAt?: string
  createdAt: string
}

export interface CreateShopRequest {
  merchantId?: string  // Optional - will auto-create merchant if not provided
  name: string
  description?: string
  address?: string
  phone?: string
  lat?: number
  lon?: number
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
  active: boolean
  sortOrder?: number
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
export type OwnerType = 'MERCHANT' | 'USER'
export type PostType = 'PHOTO' | 'VIDEO' | 'CAROUSEL'
export type PostVisibility = 'PUBLIC' | 'FOLLOWERS' | 'PRIVATE'
export type PostStatus = 'ACTIVE' | 'ARCHIVED' | 'DELETED'
export type MediaType = 'IMAGE' | 'VIDEO'
export type FollowTargetType = 'MERCHANT' | 'USER'

export interface PostMediaDto {
  id?: string
  mediaType: MediaType
  url: string
  thumbUrl?: string
  sortOrder?: number
  durationSeconds?: number
  width?: number
  height?: number
}

export interface Post {
  id: string
  ownerType: OwnerType
  ownerId: string
  ownerName?: string
  text?: string
  postType: PostType
  geoLat?: number
  geoLon?: number
  visibility: PostVisibility
  status: PostStatus
  likesCount: number
  commentsCount: number
  sharesCount?: number
  media?: PostMediaDto[]
  tags?: string[]
  isLikedByCurrentUser?: boolean
  isSavedByCurrentUser?: boolean
  createdAt: string
  updatedAt?: string
}

export interface CreatePostRequest {
  ownerType: OwnerType
  ownerId: string
  text?: string
  postType: PostType
  geoLat?: number
  geoLon?: number
  visibility?: PostVisibility
  media?: PostMediaDto[]
  tags?: string[]
  placeIds?: string[]
}

export interface Comment {
  id: string
  postId: string
  userId: string
  userName?: string
  text: string
  isFlagged?: boolean
  verifiedPurchase?: boolean
  createdAt: string
  updatedAt?: string
}

export interface CreateCommentRequest {
  postId: string
  text: string
}

export interface LikeRequest {
  postId: string
}

export interface FollowRequest {
  targetType: FollowTargetType
  targetId: string
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

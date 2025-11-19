package kg.bishkek.fucent.fusent.enums;

/**
 * User roles in the system:
 * - BUYER: Regular customer who can browse and purchase products
 * - SELLER: Employee who can manage products for assigned shops
 * - MERCHANT: Shop owner who can manage shops, products, and employees
 * - ADMIN: System administrator with full access
 */
public enum Role {
    BUYER,      // Покупатель - может просматривать и покупать товары
    SELLER,     // Продавец - сотрудник, может управлять товарами назначенных магазинов
    MERCHANT,   // Мерчант - владелец магазинов, может управлять магазинами, товарами и сотрудниками
    ADMIN       // Администратор - полный доступ к системе
}
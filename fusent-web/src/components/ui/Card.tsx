import { HTMLAttributes } from 'react'

interface CardProps extends HTMLAttributes<HTMLDivElement> {}

export const Card = ({ className = '', children, ...props }: CardProps) => {
  return (
    <div
      className={`bg-white rounded-lg shadow-md ${className}`}
      {...props}
    >
      {children}
    </div>
  )
}

interface CardContentProps extends HTMLAttributes<HTMLDivElement> {}

export const CardContent = ({ className = '', children, ...props }: CardContentProps) => {
  return (
    <div className={`p-6 ${className}`} {...props}>
      {children}
    </div>
  )
}
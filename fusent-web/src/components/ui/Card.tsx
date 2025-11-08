import { ReactNode } from 'react'
import { clsx } from 'clsx'

interface CardProps {
  children: ReactNode
  className?: string
  onClick?: () => void
  hover?: boolean
}

export const Card = ({ children, className, onClick, hover = false }: CardProps) => {
  return (
    <div
      className={clsx(
        'bg-white rounded-lg shadow-sm border border-gray-200',
        hover && 'transition-shadow duration-200 hover:shadow-md',
        onClick && 'cursor-pointer',
        className
      )}
      onClick={onClick}
    >
      {children}
    </div>
  )
}

export const CardHeader = ({ children, className }: { children: ReactNode; className?: string }) => {
  return (
    <div className={clsx('px-6 py-4 border-b border-gray-200', className)}>
      {children}
    </div>
  )
}

export const CardContent = ({ children, className }: { children: ReactNode; className?: string }) => {
  return (
    <div className={clsx('px-6 py-4', className)}>
      {children}
    </div>
  )
}

export const CardFooter = ({ children, className }: { children: ReactNode; className?: string }) => {
  return (
    <div className={clsx('px-6 py-4 border-t border-gray-200 bg-gray-50', className)}>
      {children}
    </div>
  )
}

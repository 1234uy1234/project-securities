import React from 'react';

// Mobile Detection Hook
export const useMobileDetection = () => {
  const [isMobile, setIsMobile] = React.useState(false);
  const [isTablet, setIsTablet] = React.useState(false);
  const [isDesktop, setIsDesktop] = React.useState(false);

  React.useEffect(() => {
    const checkDevice = () => {
      const userAgent = navigator.userAgent;
      const mobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(userAgent);
      const tablet = /iPad|Android/i.test(userAgent) && window.innerWidth >= 768;
      const desktop = !mobile && !tablet;

      setIsMobile(mobile && !tablet);
      setIsTablet(tablet);
      setIsDesktop(desktop);
    };

    checkDevice();
    window.addEventListener('resize', checkDevice);
    return () => window.removeEventListener('resize', checkDevice);
  }, []);

  return { isMobile, isTablet, isDesktop };
};

// Mobile-Optimized Container
interface MobileContainerProps {
  children: React.ReactNode;
  className?: string;
}

export const MobileContainer: React.FC<MobileContainerProps> = ({ 
  children, 
  className = '' 
}) => {
  const { isMobile, isTablet } = useMobileDetection();

  return (
    <div className={`
      ${isMobile ? 'px-2 py-1' : isTablet ? 'px-4 py-2' : 'px-6 py-4'}
      ${className}
    `}>
      {children}
    </div>
  );
};

// Mobile-Optimized Card
interface MobileCardProps {
  children: React.ReactNode;
  className?: string;
  title?: string;
}

export const MobileCard: React.FC<MobileCardProps> = ({ 
  children, 
  className = '',
  title 
}) => {
  const { isMobile, isTablet } = useMobileDetection();

  return (
    <div className={`
      bg-white rounded-lg shadow-md
      ${isMobile ? 'p-3 mb-3' : isTablet ? 'p-4 mb-4' : 'p-6 mb-6'}
      ${className}
    `}>
      {title && (
        <h2 className={`
          font-semibold text-gray-900 mb-4
          ${isMobile ? 'text-lg' : 'text-xl'}
        `}>
          {title}
        </h2>
      )}
      {children}
    </div>
  );
};

// Mobile-Optimized Button
interface MobileButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger' | 'success';
  size?: 'sm' | 'md' | 'lg';
  fullWidth?: boolean;
}

export const MobileButton: React.FC<MobileButtonProps> = ({ 
  children, 
  variant = 'primary',
  size = 'md',
  fullWidth = false,
  className = '',
  ...props 
}) => {
  const { isMobile } = useMobileDetection();

  const baseClasses = 'font-medium rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2';
  
  const variantClasses = {
    primary: 'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500',
    secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300 focus:ring-gray-500',
    danger: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500',
    success: 'bg-green-600 text-white hover:bg-green-700 focus:ring-green-500'
  };

  const sizeClasses = {
    sm: isMobile ? 'px-3 py-2 text-sm' : 'px-3 py-2 text-sm',
    md: isMobile ? 'px-4 py-3 text-base' : 'px-4 py-2 text-base',
    lg: isMobile ? 'px-6 py-4 text-lg' : 'px-6 py-3 text-lg'
  };

  const widthClasses = fullWidth ? 'w-full' : '';

  return (
    <button
      className={`${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]} ${widthClasses} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
};

// Mobile-Optimized Input
interface MobileInputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

export const MobileInput: React.FC<MobileInputProps> = ({ 
  label, 
  error, 
  className = '',
  ...props 
}) => {
  const { isMobile } = useMobileDetection();

  return (
    <div className="mb-4">
      {label && (
        <label className={`
          block text-sm font-medium text-gray-700 mb-2
          ${isMobile ? 'text-sm' : 'text-base'}
        `}>
          {label}
        </label>
      )}
      <input
        className={`
          w-full border border-gray-300 rounded-lg
          ${isMobile ? 'px-3 py-3 text-base' : 'px-3 py-2 text-sm'}
          focus:ring-2 focus:ring-blue-500 focus:border-blue-500
          ${error ? 'border-red-500 focus:ring-red-500 focus:border-red-500' : ''}
          ${className}
        `}
        {...props}
      />
      {error && (
        <p className="mt-1 text-sm text-red-600">{error}</p>
      )}
    </div>
  );
};

// Mobile-Optimized Table
interface MobileTableProps {
  headers: string[];
  data: any[][];
  className?: string;
}

export const MobileTable: React.FC<MobileTableProps> = ({ 
  headers, 
  data, 
  className = '' 
}) => {
  const { isMobile } = useMobileDetection();

  if (isMobile) {
    // Mobile: Card layout
    return (
      <div className={`space-y-3 ${className}`}>
        {data.map((row, index) => (
          <div key={index} className="bg-gray-50 rounded-lg p-3">
            {headers.map((header, headerIndex) => (
              <div key={headerIndex} className="flex justify-between items-center py-1">
                <span className="text-sm font-medium text-gray-600">{header}:</span>
                <span className="text-sm text-gray-900">{row[headerIndex]}</span>
              </div>
            ))}
          </div>
        ))}
      </div>
    );
  }

  // Desktop: Table layout
  return (
    <div className={`overflow-x-auto ${className}`}>
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            {headers.map((header, index) => (
              <th key={index} className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                {header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {data.map((row, index) => (
            <tr key={index}>
              {row.map((cell, cellIndex) => (
                <td key={cellIndex} className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {cell}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

// Mobile-Optimized Modal
interface MobileModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
  size?: 'sm' | 'md' | 'lg' | 'full';
}

export const MobileModal: React.FC<MobileModalProps> = ({ 
  isOpen, 
  onClose, 
  title, 
  children, 
  size = 'md' 
}) => {
  const { isMobile } = useMobileDetection();

  if (!isOpen) return null;

  const sizeClasses = {
    sm: isMobile ? 'w-full h-full' : 'max-w-md',
    md: isMobile ? 'w-full h-full' : 'max-w-lg',
    lg: isMobile ? 'w-full h-full' : 'max-w-2xl',
    full: 'w-full h-full'
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className={`
        bg-white rounded-lg shadow-xl
        ${sizeClasses[size]}
        ${isMobile ? 'w-full h-full rounded-none' : ''}
      `}>
        <div className="flex justify-between items-center p-4 border-b">
          <h3 className={`
            font-semibold text-gray-900
            ${isMobile ? 'text-lg' : 'text-xl'}
          `}>
            {title}
          </h3>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <div className={`
          ${isMobile ? 'p-4 h-full overflow-y-auto' : 'p-6'}
        `}>
          {children}
        </div>
      </div>
    </div>
  );
};

// Mobile-Optimized Grid
interface MobileGridProps {
  children: React.ReactNode;
  cols?: number;
  gap?: number;
  className?: string;
}

export const MobileGrid: React.FC<MobileGridProps> = ({ 
  children, 
  cols = 2, 
  gap = 4,
  className = '' 
}) => {
  const { isMobile } = useMobileDetection();

  const gridCols = isMobile ? 1 : cols;
  const gridGap = isMobile ? 2 : gap;

  return (
    <div className={`
      grid gap-${gridGap}
      ${gridCols === 1 ? 'grid-cols-1' : 
        gridCols === 2 ? 'grid-cols-1 md:grid-cols-2' :
        gridCols === 3 ? 'grid-cols-1 md:grid-cols-2 lg:grid-cols-3' :
        'grid-cols-1 md:grid-cols-2 lg:grid-cols-4'}
      ${className}
    `}>
      {children}
    </div>
  );
};

// Mobile-Optimized Loading Spinner
interface MobileSpinnerProps {
  size?: 'sm' | 'md' | 'lg';
  text?: string;
}

export const MobileSpinner: React.FC<MobileSpinnerProps> = ({ 
  size = 'md', 
  text = 'Đang tải...' 
}) => {
  const { isMobile } = useMobileDetection();

  const sizeClasses = {
    sm: isMobile ? 'w-4 h-4' : 'w-4 h-4',
    md: isMobile ? 'w-8 h-8' : 'w-6 h-6',
    lg: isMobile ? 'w-12 h-12' : 'w-8 h-8'
  };

  return (
    <div className="flex flex-col items-center justify-center p-4">
      <div className={`
        animate-spin rounded-full border-b-2 border-blue-600
        ${sizeClasses[size]}
      `}></div>
      {text && (
        <p className={`
          mt-2 text-gray-600
          ${isMobile ? 'text-sm' : 'text-base'}
        `}>
          {text}
        </p>
      )}
    </div>
  );
};

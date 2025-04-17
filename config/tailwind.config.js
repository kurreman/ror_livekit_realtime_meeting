module.exports = {
  content: [
    './app/views/**/*.{html,html.erb,erb,rb}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js'
  ],
  darkMode: 'media', // Enable media queries for system appearance detection
  theme: {
    extend: {
      colors: {
        'custom-black': '#050505',
        'custom-dark': '#111111',
        'custom-gray': {
          100: '#f5f5f5',
          200: '#e5e5e5',
          300: '#d4d4d4',
          400: '#a3a3a3',
          500: '#737373',
          600: '#525252',
          700: '#404040',
          800: '#262626',
          900: '#171717',
        },
        'custom-blue': {
          400: '#60a5fa',
          500: '#3b82f6',
          600: '#2563eb',
        },
        'custom-purple': {
          400: '#c084fc',
          500: '#a855f7',
          600: '#9333ea',
        },
        'custom-light': '#f8f9fa',
        'custom-light-accent': '#e9ecef',
      },
      backgroundImage: {
        'custom-gradient': 'linear-gradient(to right, var(--tw-gradient-stops))',
      },
      animation: {
        'custom-fade-in': 'fadeIn 0.5s ease-out',
        'custom-slide-up': 'slideUp 0.5s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(20px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        }
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}

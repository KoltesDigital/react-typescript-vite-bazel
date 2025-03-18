import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react-swc';

// https://vite.dev/config/
export default defineConfig({
  build: {
    rollupOptions: {
      external: ['react', 'react-dom/client'],
      output: {
        paths: {
          react: 'https://esm.sh/react@19.0.0',
          'react-dom/client': 'https://esm.sh/react-dom@19.0.0/client',
        },
      },
    },
  },
  plugins: [react()],
});

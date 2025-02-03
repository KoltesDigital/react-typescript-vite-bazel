import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react-swc';
import { fileURLToPath, URL } from 'url';

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: [
      {
        find: '@generator',
        replacement: fileURLToPath(new URL('./generator', import.meta.url)),
      },
    ],
  },
});

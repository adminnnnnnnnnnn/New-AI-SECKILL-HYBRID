import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8084',  // 直接代理到秒杀服务
        changeOrigin: true,
        rewrite: (path) => {
          let newPath = path.replace(/^\/api/, '');
          // 如果路径以 /ai/ 开头，将其重写为 /seckill/ai/
          if (newPath.startsWith('/ai/')) {
            newPath = newPath.replace(/^\/ai\//, '/seckill/ai/');
          }
          return newPath;
        }
      }
    }
  }
})
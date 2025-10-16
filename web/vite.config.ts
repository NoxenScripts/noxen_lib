import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import fs from 'node:fs'
import path from 'node:path'

function renameIndexToUiHtml() {
  return {
    name: 'rename-index-to-uihtml',
    closeBundle() {
      const outDir = path.resolve(__dirname, '../ui')
      const indexPath = path.join(outDir, 'index.html')
      const uiPath = path.join(outDir, 'ui.html')
      if (!fs.existsSync(outDir)) return
      if (fs.existsSync(indexPath)) {
        if (fs.existsSync(uiPath)) fs.unlinkSync(uiPath)
        fs.renameSync(indexPath, uiPath)
      }
    },
  }
}

export default defineConfig({
  plugins: [vue(), renameIndexToUiHtml()],
  root: '.',
  base: './',
  build: {
    outDir: '../ui',
    emptyOutDir: true,
    rollupOptions: {
      input: 'index.html',
    },
  },
})

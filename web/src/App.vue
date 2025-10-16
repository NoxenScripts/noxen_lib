<script setup lang="ts">
import { ref } from 'vue'
import ProgressBar from './components/ProgressBar.vue'

const showProgress = ref(false)
const progressValue = ref(50)
const icon = ref('📊')
const label = ref('Progress')
const style = ref('rectangle')
const position = ref('bottom')

function handleProgressUpdate(value: number) {
  progressValue.value = value
  console.log('Progress updated:', value)
}

function handleIncrease(value: number) {
  console.log('Progress increased to:', value)
}

function handleDecrease(value: number) {
  console.log('Progress decreased to:', value)
}

function handleMessage(event: MessageEvent) {
  const { action, data } = event.data

  if (action === 'showProgress') {
    showProgress.value = true
    if (data?.value !== undefined) {
      progressValue.value = data.value
    }
    if (data?.icon !== undefined) {
      icon.value = data.icon
    }
    if (data?.label !== undefined) {
      label.value = data.label
    }
    if (data?.style !== undefined) {
      style.value = data.style === 'circle' ? 'circle' : 'rectangle'
    }
    if (data?.position !== undefined) {
      position.value = data.position === 'center' ? 'center' : 'bottom'
    }
  } else if (action === 'hideProgress') {
    showProgress.value = false
  } else if (action === 'updateProgress') {
    progressValue.value = data?.value || 0
  }
}

// Listen for messages when mounted
import { onMounted } from 'vue'
onMounted(() => {
  window.addEventListener('message', handleMessage)
})
</script>

<template>
  <div id="app">
    <ProgressBar
      v-if="showProgress"
      :value="progressValue"
      :max="100"
      :min="0"
      :step="5"
      :label="label"
      :icon="icon"
      :shape="style"
      :position="position"
      @update="handleProgressUpdate"
      @increase="handleIncrease"
      @decrease="handleDecrease"
    />
  </div>
</template>

<style scoped>
/* App specific styles can be added here */
</style>

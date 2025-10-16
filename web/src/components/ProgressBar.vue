<script setup lang="ts">
import { ref, computed } from 'vue'

interface Props {
  label?: string
  value?: number
  max?: number
  min?: number
  step?: number
  icon?: string
  position?: 'bottom' | 'center'
  shape?: 'rectangle' | 'circle'
}

const props = withDefaults(defineProps<Props>(), {
  label: 'Progress',
  value: 50,
  max: 100,
  min: 0,
  step: 1,
  icon: '📊',
  position: 'bottom',
  shape: 'rectangle'
})

const emit = defineEmits<{
  update: [value: number]
  increase: [value: number]
  decrease: [value: number]
}>()

const currentValue = ref(props.value)

const percentage = computed(() => {
  const val = Math.max(props.min, Math.min(props.max, currentValue.value))
  return ((val - props.min) / (props.max - props.min)) * 100
})

const progressStyle = computed(() => ({
  width: `${percentage.value}%`
}))

const rootClass = computed(() => ({
  'progress-root': true,
  bottom: props.position === 'bottom',
  center: props.position === 'center',
  'shape-rectangle': props.shape === 'rectangle',
  'shape-circle': props.shape === 'circle',
}))

function increase() {
  const newValue = Math.min(props.max, currentValue.value + props.step)
  currentValue.value = newValue
  emit('increase', newValue)
  emit('update', newValue)
}

function decrease() {
  const newValue = Math.max(props.min, currentValue.value - props.step)
  currentValue.value = newValue
  emit('decrease', newValue)
  emit('update', newValue)
}

function setValue(value: number) {
  const clampedValue = Math.max(props.min, Math.min(props.max, value))
  currentValue.value = clampedValue
  emit('update', clampedValue)
}

import { watch } from 'vue'
watch(() => props.value, (newValue) => {
  currentValue.value = newValue
})
</script>

<template>
  <div :class="rootClass">
    <div class="progress-bar-container">
      <div class="progress-icon-bg" v-if="shape === 'rectangle'">
        <span>{{ icon }}</span>
      </div>
      <div class="progress-wrapper">
        <div class="progress-bg" :style="shape === 'circle' ? { '--p': percentage } : {}">
          <div
            v-if="shape === 'rectangle'"
            class="progress-fill"
            :style="progressStyle"
          ></div>
          <div class="progress-inside-label">{{ label }}</div>
        </div>
      </div>
      <span class="progress-value">{{ Math.round(currentValue) }}/{{ max }}</span>
    </div>
  </div>
</template>

<style scoped>
/* Additional scoped styles can be added here if needed */
</style>

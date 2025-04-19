<template>
  <div class="todo-filter">
    <div class="filter-buttons">
      <button 
        @click="setFilter('all')" 
        :class="{ active: activeFilter === 'all' }"
      >
        Все
      </button>
      <button 
        @click="setFilter('active')" 
        :class="{ active: activeFilter === 'active' }"
      >
        Активные
      </button>
      <button 
        @click="setFilter('completed')"
        :class="{ active: activeFilter === 'completed' }"
      >
        Выполненные
      </button>
    </div>
    <div class="todo-count">
      <span>{{ activeTodosCount }} активных задач</span>
    </div>
  </div>
</template>

<script>
import { ref, computed } from 'vue';
import { useStore } from 'vuex';

export default {
  name: 'TodoFilter',
  emits: ['filter-change'],
  setup(props, { emit }) {
    const store = useStore();
    const activeFilter = ref('all');

    const activeTodosCount = computed(() => {
      return store.getters.activeTodos.length;
    });

    const setFilter = (filter) => {
      activeFilter.value = filter;
      emit('filter-change', filter);
    };

    return {
      activeFilter,
      activeTodosCount,
      setFilter
    };
  }
};
</script>

<style scoped>
.todo-filter {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #eee;
}

.filter-buttons {
  display: flex;
  gap: 0.5rem;
}

button {
  background-color: #f5f5f5;
  color: #42b983;
  border: 1px solid #42b983;
}

button.active {
  background-color: #42b983;
  color: white;
}

.todo-count {
  font-size: 0.9rem;
  color: #666;
}
</style> 
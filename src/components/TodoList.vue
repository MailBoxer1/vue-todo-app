<template>
  <div class="todo-list">
    <div v-if="filteredTodos.length === 0" class="empty-list">
      <p>{{ emptyMessage }}</p>
    </div>
    <ul v-else>
      <TodoItem 
        v-for="todo in filteredTodos" 
        :key="todo.id" 
        :todo="todo"
      />
    </ul>
  </div>
</template>

<script>
import { computed, ref } from 'vue';
import { useStore } from 'vuex';
import TodoItem from './TodoItem.vue';

export default {
  name: 'TodoList',
  components: {
    TodoItem
  },
  setup() {
    const store = useStore();
    const filter = ref('all');

    const todos = computed(() => store.getters.allTodos);
    
    const filteredTodos = computed(() => {
      switch (filter.value) {
        case 'active':
          return store.getters.activeTodos;
        case 'completed':
          return store.getters.completedTodos;
        default:
          return store.getters.allTodos;
      }
    });

    const emptyMessage = computed(() => {
      switch (filter.value) {
        case 'active':
          return 'Нет активных задач';
        case 'completed':
          return 'Нет выполненных задач';
        default:
          return 'Список задач пуст';
      }
    });

    // Обработчик изменения фильтра из компонента TodoFilter
    const handleFilterChange = (newFilter) => {
      filter.value = newFilter;
    };

    return {
      todos,
      filteredTodos,
      emptyMessage,
      filter,
      handleFilterChange
    };
  }
};
</script>

<style scoped>
.todo-list {
  min-height: 100px;
}

ul {
  list-style: none;
  padding: 0;
}

.empty-list {
  text-align: center;
  color: #999;
  padding: 2rem 0;
  font-style: italic;
}
</style>

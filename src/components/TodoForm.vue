<template>
  <div class="todo-form">
    <form @submit.prevent="addTodo">
      <input 
        type="text" 
        v-model="todoText" 
        placeholder="Добавить новую задачу..."
        :class="{ 'error': error }"
      />
      <button type="submit">Добавить</button>
    </form>
    <p v-if="error" class="error-message">{{ error }}</p>
  </div>
</template>

<script>
import { useStore } from 'vuex';
import { ref } from 'vue';

export default {
  name: 'TodoForm',
  setup() {
    const store = useStore();
    const todoText = ref('');
    const error = ref('');

    const addTodo = () => {
      if (todoText.value.trim() === '') {
        error.value = 'Задача не может быть пустой';
        return;
      }
      
      store.dispatch('addTodo', todoText.value.trim());
      todoText.value = '';
      error.value = '';
    };

    return {
      todoText,
      error,
      addTodo
    };
  }
};
</script>

<style scoped>
.todo-form {
  margin-bottom: 2rem;
}

form {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

input {
  flex: 1;
}

input.error {
  border-color: #ff5252;
}

.error-message {
  color: #ff5252;
  font-size: 0.8rem;
  margin-top: 0.5rem;
  text-align: left;
}
</style> 
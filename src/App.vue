<template>
  <div id="app">
    <div class="container">
      <h1>Todo App</h1>
      <TodoForm />
      <TodoFilter @filter-change="handleFilterChange" />
      <TodoList ref="todoList" />
    </div>
  </div>
</template>

<script>
import TodoList from './components/TodoList.vue';
import TodoForm from './components/TodoForm.vue';
import TodoFilter from './components/TodoFilter.vue';

export default {
  name: 'App',
  components: {
    TodoList,
    TodoForm,
    TodoFilter
  },
  methods: {
    handleFilterChange(filter) {
      if (this.$refs.todoList) {
        this.$refs.todoList.handleFilterChange(filter);
      }
    }
  }
}
</script>

<style>
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #f5f5f5;
  color: #2c3e50;
}

#app {
  width: 100%;
  max-width: 960px;
  margin: 0 auto;
  padding: 2rem;
}

.container {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 2rem;
}

h1 {
  text-align: center;
  margin-bottom: 2rem;
  color: #42b983;
}

button {
  cursor: pointer;
  background-color: #42b983;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  font-size: 0.9rem;
  transition: background-color 0.3s;
}

button:hover {
  background-color: #3aa876;
}

input[type="text"] {
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 0.9rem;
  width: 100%;
}
</style>

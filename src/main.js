import { createApp } from 'vue'
import { createStore } from 'vuex'
import App from './App.vue'

// Создание Vuex хранилища
const store = createStore({
  state() {
    return {
      todos: JSON.parse(localStorage.getItem('todos')) || []
    }
  },
  mutations: {
    ADD_TODO(state, todo) {
      state.todos.push(todo);
      localStorage.setItem('todos', JSON.stringify(state.todos));
    },
    REMOVE_TODO(state, id) {
      state.todos = state.todos.filter(todo => todo.id !== id);
      localStorage.setItem('todos', JSON.stringify(state.todos));
    },
    TOGGLE_TODO(state, id) {
      const todo = state.todos.find(todo => todo.id === id);
      if (todo) {
        todo.completed = !todo.completed;
        localStorage.setItem('todos', JSON.stringify(state.todos));
      }
    },
    UPDATE_TODO(state, { id, text }) {
      const todo = state.todos.find(todo => todo.id === id);
      if (todo) {
        todo.text = text;
        localStorage.setItem('todos', JSON.stringify(state.todos));
      }
    }
  },
  actions: {
    addTodo({ commit }, text) {
      const newTodo = {
        id: Date.now(),
        text,
        completed: false
      };
      commit('ADD_TODO', newTodo);
    },
    removeTodo({ commit }, id) {
      commit('REMOVE_TODO', id);
    },
    toggleTodo({ commit }, id) {
      commit('TOGGLE_TODO', id);
    },
    updateTodo({ commit }, payload) {
      commit('UPDATE_TODO', payload);
    }
  },
  getters: {
    allTodos: state => state.todos,
    activeTodos: state => state.todos.filter(todo => !todo.completed),
    completedTodos: state => state.todos.filter(todo => todo.completed)
  }
});

// Создание и монтирование Vue приложения
const app = createApp(App);
app.use(store);
app.mount('#app');

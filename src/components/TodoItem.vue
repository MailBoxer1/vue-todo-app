<template>
  <li class="todo-item" :class="{ 'editing': isEditing }">
    <div class="todo-view" v-if="!isEditing">
      <div class="todo-content">
        <input 
          type="checkbox" 
          :checked="todo.completed" 
          @change="toggleComplete"
        />
        <span 
          :class="{ 'completed': todo.completed }"
          @dblclick="startEditing"
        >
          {{ todo.text }}
        </span>
      </div>
      <div class="todo-actions">
        <button class="edit-btn" @click="startEditing">
          ✏️
        </button>
        <button class="delete-btn" @click="removeTodo">
          🗑️
        </button>
      </div>
    </div>
    <div class="todo-edit" v-else>
      <input 
        type="text"
        v-model="editText"
        @keyup.enter="saveEdit"
        @keyup.esc="cancelEdit"
        @blur="saveEdit"
        ref="editInput"
      />
    </div>
  </li>
</template>

<script>
import { ref } from 'vue';
import { useStore } from 'vuex';

export default {
  name: 'TodoItem',
  props: {
    todo: {
      type: Object,
      required: true
    }
  },
  setup(props) {
    const store = useStore();
    const isEditing = ref(false);
    const editText = ref('');
    const editInput = ref(null);

    const toggleComplete = () => {
      store.dispatch('toggleTodo', props.todo.id);
    };

    const removeTodo = () => {
      store.dispatch('removeTodo', props.todo.id);
    };

    const startEditing = () => {
      editText.value = props.todo.text;
      isEditing.value = true;
      
      // Фокус на инпуте при следующем цикле рендеринга
      setTimeout(() => {
        if (editInput.value) {
          editInput.value.focus();
        }
      });
    };

    const saveEdit = () => {
      if (editText.value.trim() !== '') {
        store.dispatch('updateTodo', { 
          id: props.todo.id, 
          text: editText.value.trim() 
        });
      }
      isEditing.value = false;
    };

    const cancelEdit = () => {
      isEditing.value = false;
    };

    return {
      isEditing,
      editText,
      editInput,
      toggleComplete,
      removeTodo,
      startEditing,
      saveEdit,
      cancelEdit
    };
  }
};
</script>

<style scoped>
.todo-item {
  display: flex;
  align-items: center;
  padding: 0.8rem 0;
  border-bottom: 1px solid #eee;
}

.todo-item:last-child {
  border-bottom: none;
}

.todo-view {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.todo-content {
  display: flex;
  align-items: center;
  gap: 0.8rem;
  flex: 1;
}

.todo-actions {
  display: flex;
  gap: 0.5rem;
}

.completed {
  text-decoration: line-through;
  color: #999;
}

.edit-btn, .delete-btn {
  background: none;
  border: none;
  font-size: 1rem;
  padding: 0.2rem;
  cursor: pointer;
}

.todo-edit {
  width: 100%;
}

.todo-edit input {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #42b983;
  border-radius: 4px;
}
</style>

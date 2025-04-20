/**
 * Реализация функционала аналогичного jQuery $(function(){})
 * Функция выполняется после загрузки DOM, даже если вызвана до загрузки
 * или немедленно, если DOM уже загружен
 * 
 * @param {Function} callback Функция, которая должна быть выполнена после загрузки DOM
 */
function $(callback) {
  // Проверяем, загружен ли уже DOM
  if (
    document.readyState === 'complete' || 
    document.readyState === 'interactive' ||
    document.readyState === 'loaded'
  ) {
    // DOM уже загружен, выполняем callback немедленно, но асинхронно
    setTimeout(callback, 0);
  } else {
    // DOM еще не загружен, добавляем обработчик события
    document.addEventListener('DOMContentLoaded', function() {
      callback();
    });
  }
}

// Пример использования:
/*
$(function() {
  console.log('DOM готов!');
  
  // Здесь можно безопасно работать с DOM
  const element = document.getElementById('example');
  if (element) {
    element.innerHTML = 'DOM загружен и готов к работе';
  }
});
*/ 
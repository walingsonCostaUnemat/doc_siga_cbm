/* ========================================
   SIGA Documentation - Process Selector JS
   ======================================== */

(function() {
  'use strict';

  function initProcessSelector() {
    var btns = document.querySelectorAll('[data-process]');
    var panels = document.querySelectorAll('[data-process-panel]');

    btns.forEach(function(btn) {
      btn.addEventListener('click', function() {
        var target = btn.getAttribute('data-process');

        // Update buttons - remove active state from all
        btns.forEach(function(b) {
          b.classList.remove('border-cbm-500', 'dark:border-cbm-500', 'bg-cbm-50', 'dark:bg-cbm-900/20');
          b.classList.add('border-slate-200', 'dark:border-slate-700');
        });

        // Set active state on clicked button
        btn.classList.remove('border-slate-200', 'dark:border-slate-700');
        btn.classList.add('border-cbm-500', 'dark:border-cbm-500', 'bg-cbm-50', 'dark:bg-cbm-900/20');

        // Show the matching panel with fade animation
        panels.forEach(function(panel) {
          if (panel.getAttribute('data-process-panel') === target) {
            panel.classList.remove('hidden');
            panel.style.opacity = '0';
            requestAnimationFrame(function() {
              panel.style.transition = 'opacity 0.4s ease';
              panel.style.opacity = '1';
            });
          } else {
            panel.classList.add('hidden');
          }
        });
      });
    });
  }

  document.addEventListener('DOMContentLoaded', function() {
    initProcessSelector();
  });
})();

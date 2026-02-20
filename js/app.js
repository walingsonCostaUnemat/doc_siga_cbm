/* ========================================
   SIGA Documentation - Core Application JS
   ======================================== */

(function () {
  'use strict';

  // ---- Dark/Light Theme ----
  function initTheme() {
    var toggle = document.getElementById('theme-toggle');
    var html = document.documentElement;

    // Check saved preference or default to dark
    var saved = localStorage.getItem('siga-theme');
    if (saved === 'light') {
      html.classList.remove('dark');
    } else {
      html.classList.add('dark');
      localStorage.setItem('siga-theme', 'dark');
    }

    if (toggle) {
      toggle.addEventListener('click', function () {
        html.classList.toggle('dark');
        var isDark = html.classList.contains('dark');
        localStorage.setItem('siga-theme', isDark ? 'dark' : 'light');
        updateThemeIcon(isDark);
      });
      updateThemeIcon(html.classList.contains('dark'));
    }
  }

  function updateThemeIcon(isDark) {
    var icon = document.getElementById('theme-icon');
    if (icon) {
      icon.className = isDark ? 'fas fa-sun' : 'fas fa-moon';
    }
  }

  // ---- Mobile Navigation ----
  function initMobileNav() {
    var hamburger = document.getElementById('hamburger');
    var mobileMenu = document.getElementById('mobile-menu');
    var overlay = document.getElementById('mobile-overlay');

    if (!hamburger || !mobileMenu) return;

    function toggleMenu() {
      hamburger.classList.toggle('active');
      mobileMenu.classList.toggle('open');
      if (overlay) overlay.classList.toggle('hidden');
      document.body.style.overflow = mobileMenu.classList.contains('open') ? 'hidden' : '';
    }

    hamburger.addEventListener('click', toggleMenu);
    if (overlay) overlay.addEventListener('click', toggleMenu);

    // Close on link click
    mobileMenu.querySelectorAll('a').forEach(function (link) {
      link.addEventListener('click', function () {
        if (mobileMenu.classList.contains('open')) toggleMenu();
      });
    });

    // Close on Escape
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && mobileMenu.classList.contains('open')) toggleMenu();
    });
  }

  // ---- Scroll Progress Bar ----
  function initScrollProgress() {
    var bar = document.getElementById('scroll-progress');
    if (!bar) return;

    window.addEventListener('scroll', function () {
      var scrollTop = window.scrollY;
      var docHeight = document.documentElement.scrollHeight - window.innerHeight;
      var progress = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;
      bar.style.width = progress + '%';
    }, { passive: true });
  }

  // ---- Header Scroll Effect ----
  function initHeaderScroll() {
    var header = document.getElementById('main-header');
    if (!header) return;

    var lastScroll = 0;
    window.addEventListener('scroll', function () {
      var current = window.scrollY;
      if (current > 80) {
        header.classList.add('shadow-lg');
        header.classList.remove('shadow-none');
      } else {
        header.classList.remove('shadow-lg');
        header.classList.add('shadow-none');
      }
      lastScroll = current;
    }, { passive: true });
  }

  // ---- Counter Animation ----
  function initCounters() {
    var counters = document.querySelectorAll('[data-count]');
    if (!counters.length) return;

    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          animateCounter(entry.target);
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.5 });

    counters.forEach(function (counter) {
      observer.observe(counter);
    });
  }

  function animateCounter(el) {
    var target = parseInt(el.getAttribute('data-count'), 10);
    var suffix = el.getAttribute('data-suffix') || '';
    var duration = 2000;
    var start = 0;
    var startTime = null;

    function step(timestamp) {
      if (!startTime) startTime = timestamp;
      var progress = Math.min((timestamp - startTime) / duration, 1);
      // Ease out cubic
      var eased = 1 - Math.pow(1 - progress, 3);
      var current = Math.floor(eased * target);
      el.textContent = current + suffix;
      if (progress < 1) {
        requestAnimationFrame(step);
      } else {
        el.textContent = target + suffix;
      }
    }

    requestAnimationFrame(step);
  }

  // ---- Back to Top ----
  function initBackToTop() {
    var btn = document.getElementById('back-to-top');
    if (!btn) return;

    window.addEventListener('scroll', function () {
      if (window.scrollY > 400) {
        btn.classList.add('visible');
      } else {
        btn.classList.remove('visible');
      }
    }, { passive: true });

    btn.addEventListener('click', function () {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }

  // ---- Active Nav Link ----
  function initActiveNav() {
    var currentPage = window.location.pathname.split('/').pop() || 'index.html';
    var links = document.querySelectorAll('.nav-link-item');

    links.forEach(function (link) {
      var href = link.getAttribute('href');
      if (href === currentPage || (currentPage === '' && href === 'index.html')) {
        link.classList.add('text-cbm-500');
        link.classList.add('nav-link-active');
      }
    });
  }

  // ---- AOS Init ----
  function initAOS() {
    if (typeof AOS !== 'undefined') {
      AOS.init({
        duration: 700,
        once: true,
        offset: 80,
        easing: 'ease-out-cubic'
      });
    }
  }

  // ---- Scroll Spy for Module Navigation ----
  function initScrollSpy() {
    var navBtns = document.querySelectorAll('[data-scroll-target]');
    if (!navBtns.length) return;

    var sections = [];
    navBtns.forEach(function (btn) {
      var targetId = btn.getAttribute('data-scroll-target');
      var section = document.getElementById(targetId);
      if (section) sections.push({ btn: btn, section: section });

      btn.addEventListener('click', function (e) {
        e.preventDefault();
        if (section) {
          var offset = 160;
          var top = section.getBoundingClientRect().top + window.scrollY - offset;
          window.scrollTo({ top: top, behavior: 'smooth' });
        }
      });
    });

    if (!sections.length) return;

    window.addEventListener('scroll', function () {
      var scrollPos = window.scrollY + 200;
      var active = null;

      sections.forEach(function (item) {
        if (item.section.offsetTop <= scrollPos) {
          active = item;
        }
      });

      navBtns.forEach(function (btn) {
        btn.classList.remove('bg-cbm-700', 'text-white');
        btn.classList.add('bg-slate-700', 'text-slate-300');
      });

      if (active) {
        active.btn.classList.remove('bg-slate-700', 'text-slate-300');
        active.btn.classList.add('bg-cbm-700', 'text-white');
      }
    }, { passive: true });
  }

  // ---- Tab Switching ----
  function initTabs() {
    document.querySelectorAll('[data-tab-group]').forEach(function (group) {
      var btns = group.querySelectorAll('[data-tab-btn]');
      var panels = group.parentElement.querySelectorAll('[data-tab-panel]');

      btns.forEach(function (btn) {
        btn.addEventListener('click', function () {
          var target = btn.getAttribute('data-tab-btn');

          btns.forEach(function (b) {
            b.classList.remove('bg-cbm-700', 'text-white');
            b.classList.add('bg-slate-700/50', 'text-slate-400');
          });
          btn.classList.remove('bg-slate-700/50', 'text-slate-400');
          btn.classList.add('bg-cbm-700', 'text-white');

          panels.forEach(function (panel) {
            if (panel.getAttribute('data-tab-panel') === target) {
              panel.classList.remove('hidden');
              panel.style.opacity = '0';
              requestAnimationFrame(function () {
                panel.style.transition = 'opacity 0.3s ease';
                panel.style.opacity = '1';
              });
            } else {
              panel.classList.add('hidden');
            }
          });
        });
      });
    });
  }

  // ---- Initialize Everything ----
  document.addEventListener('DOMContentLoaded', function () {
    initTheme();
    initMobileNav();
    initScrollProgress();
    initHeaderScroll();
    initCounters();
    initBackToTop();
    initActiveNav();
    initAOS();
    initScrollSpy();
    initTabs();
  });

})();

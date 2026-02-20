(function() {
    'use strict';

    var viewer = null;
    var gallery = null;

    /**
     * Initialize filter buttons for diagram categories
     */
    function initFilters() {
        var filterBtns = document.querySelectorAll('[data-filter]');
        var cards = document.querySelectorAll('.diagram-card');
        var countEl = document.getElementById('diagram-count');
        var emptyState = document.getElementById('empty-state');
        var galleryEl = document.getElementById('diagram-gallery');

        filterBtns.forEach(function(btn) {
            btn.addEventListener('click', function() {
                var filter = btn.getAttribute('data-filter');

                // Update active button styles
                filterBtns.forEach(function(b) {
                    b.classList.remove('bg-cbm-700', 'text-white');
                    b.classList.add('bg-slate-200', 'dark:bg-slate-700/50', 'text-slate-600', 'dark:text-slate-400');
                });
                btn.classList.remove('bg-slate-200', 'dark:bg-slate-700/50', 'text-slate-600', 'dark:text-slate-400');
                btn.classList.add('bg-cbm-700', 'text-white');

                // Filter cards with animation
                var visible = 0;
                cards.forEach(function(card) {
                    var category = card.getAttribute('data-category');
                    if (filter === 'todos' || category === filter) {
                        card.style.display = '';
                        card.style.opacity = '0';
                        card.style.transform = 'translateY(10px)';
                        requestAnimationFrame(function() {
                            requestAnimationFrame(function() {
                                card.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                                card.style.opacity = '1';
                                card.style.transform = 'translateY(0)';
                            });
                        });
                        visible++;
                    } else {
                        card.style.display = 'none';
                    }
                });

                // Update count
                if (countEl) {
                    countEl.textContent = visible;
                }

                // Toggle empty state
                if (emptyState && galleryEl) {
                    if (visible === 0) {
                        emptyState.classList.remove('hidden');
                        galleryEl.classList.add('hidden');
                    } else {
                        emptyState.classList.add('hidden');
                        galleryEl.classList.remove('hidden');
                    }
                }

                // Rebuild viewer to reflect visible images
                rebuildViewer();
            });
        });
    }

    /**
     * Rebuild the Viewer.js instance to match currently visible images
     */
    function rebuildViewer() {
        if (viewer) {
            viewer.destroy();
            viewer = null;
        }
        initViewer();
    }

    /**
     * Initialize Viewer.js lightbox on the gallery
     */
    function initViewer() {
        gallery = document.getElementById('diagram-gallery');
        if (!gallery || typeof Viewer === 'undefined') return;

        viewer = new Viewer(gallery, {
            filter: function(image) {
                var card = image.closest('.diagram-card');
                return card && card.style.display !== 'none';
            },
            toolbar: {
                zoomIn: 1,
                zoomOut: 1,
                oneToOne: 1,
                reset: 1,
                prev: 1,
                play: 0,
                next: 1,
                rotateLeft: 0,
                rotateRight: 0,
                flipHorizontal: 0,
                flipVertical: 0
            },
            navbar: true,
            title: true,
            tooltip: true,
            movable: true,
            zoomable: true,
            scalable: true,
            transition: true,
            fullscreen: true,
            keyboard: true,
            url: 'src'
        });
    }

    /**
     * Global function to open viewer at a specific image index.
     * Computes the visible index based on currently displayed cards.
     */
    window.openViewer = function(index) {
        if (!viewer) return;

        // Get all diagram cards
        var cards = document.querySelectorAll('.diagram-card');
        var visibleIndex = 0;
        var targetFound = false;

        for (var i = 0; i < cards.length; i++) {
            if (cards[i].style.display === 'none') continue;
            if (i === index) {
                targetFound = true;
                break;
            }
            visibleIndex++;
        }

        if (targetFound) {
            viewer.view(visibleIndex);
        }
    };

    /**
     * Initialize everything on DOM ready
     */
    document.addEventListener('DOMContentLoaded', function() {
        initFilters();
        initViewer();
    });
})();

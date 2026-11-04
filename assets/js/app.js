document.addEventListener('DOMContentLoaded', () => {
    const menuButton = document.querySelector('[data-menu-toggle]');
    const nav = document.querySelector('.topnav');
    menuButton?.addEventListener('click', () => nav?.classList.toggle('nav-open'));

    document.querySelectorAll('.alert-close').forEach(button => {
        button.addEventListener('click', () => button.closest('.alert')?.remove());
    });

    document.querySelectorAll('[data-confirm]').forEach(form => {
        form.addEventListener('submit', event => {
            if (!window.confirm(form.dataset.confirm || 'Are you sure?')) event.preventDefault();
        });
    });

    document.querySelectorAll('[data-level-range]').forEach(range => {
        const output = document.querySelector(range.dataset.output);
        const labels = ['No experience', 'Beginner', 'Basic', 'Intermediate', 'Advanced', 'Expert'];
        const update = () => { if (output) output.textContent = labels[Number(range.value)] || labels[0]; };
        range.addEventListener('input', update); update();
    });

    document.querySelectorAll('[data-search-input]').forEach(input => {
        const target = document.querySelector(input.dataset.searchInput);
        input.addEventListener('input', () => {
            const query = input.value.trim().toLowerCase();
            target?.querySelectorAll('[data-search-item]').forEach(item => {
                item.hidden = !item.textContent.toLowerCase().includes(query);
            });
        });
    });

    document.querySelectorAll('[data-password-toggle]').forEach(button => {
        button.addEventListener('click', () => {
            const input = document.getElementById(button.dataset.passwordToggle);
            if (!input) return;
            input.type = input.type === 'password' ? 'text' : 'password';
            button.textContent = input.type === 'password' ? 'Show' : 'Hide';
        });
    });
});

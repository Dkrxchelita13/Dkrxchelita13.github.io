const toggle = document.querySelector('.nav-toggle');
const navigation = document.querySelector('#primary-navigation');

if (toggle && navigation) {
  toggle.addEventListener('click', () => {
    const isOpen = navigation.classList.toggle('is-open');
    toggle.setAttribute('aria-expanded', String(isOpen));
  });

  navigation.querySelectorAll('a').forEach((link) => {
    link.addEventListener('click', () => {
      navigation.classList.remove('is-open');
      toggle.setAttribute('aria-expanded', 'false');
    });
  });
}

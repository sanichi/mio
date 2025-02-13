document.addEventListener("DOMContentLoaded", () => {
  // TODO: this shouldn't be necessary once Turbo is on by default
  $('[data-toggle="tooltip"]').tooltip();
});
document.addEventListener("turbo:visit", () => {
  // const els = document.querySelectorAll('[data-toggle="tooltip"]');
  // [...els].forEach((el) => { el.tooltip() }); FIX: el.tooltip is not a function
  $('[data-toggle="tooltip"]').tooltip();
});

$(function() {
  if ($(".slider div img").length > 0) {
    $('.slider').slides({
      generatePagination: false,
      next: "next",
      prev: "prev"
    });
  }
});
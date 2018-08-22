document.addEventListener('turbolinks:load', function (e) {

    document.dispatchEvent(new CustomEvent('page:load', e));
});

document.addEventListener("turbolinks:before-cache", function ($event) {

    // dont cache flash messages
    $($event.originalEvent.data.newBody).remove(".flash-message")
});




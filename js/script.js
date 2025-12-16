// Get modal
var modal = document.getElementById("loginModal");
var btn = document.getElementById("loginBtn");
var span = document.getElementsByClassName("close")[0];

// Open modal
btn.onclick = function() { modal.style.display = "block"; }

// Close modal
span.onclick = function() { modal.style.display = "none"; }
window.onclick = function(event) { if(event.target == modal) { modal.style.display = "none"; } }

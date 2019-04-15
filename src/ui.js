function msgMousePos(event) {
    Blink.msg("click", [event.clientX, event.clientY]);
}
alg.onchange = function () {
    Blink.msg("alg_select", []);
}

alg = document.getElementById("algorithm");
document.addEventListener("click", f);

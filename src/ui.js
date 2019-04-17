<script type="text/javascript">
    function msgMousePos(event) {
        Blink.msg("click", [event.clientX, event.clientY]);
    }
    document.addEventListener("click", f);

    alg = document.getElementById("algorithm");
    alg.onchange = function () {
        Blink.msg("alg_select", []);
    }
</script>

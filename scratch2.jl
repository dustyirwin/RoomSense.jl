using WebIO
using JSExpr # you may need to install this package
using Mux


function counter(start=0)
    scope = Scope()

    # updates to this update the UI
    count = Observable(scope, "count", start)

    onjs(count, # listen on JavaScript
         JSExpr.@js x->this.dom.querySelector("#count").src = x)

    on(count) do n # listen on Julia
        println(n > 0 ? "+"^n : "-"^abs(n))
    end

    btn(label, d) = dom"button"(
        label,
        events=Dict(
            "click" => JSExpr.@js () -> $count[] = $count[] + $d
        )
    )

    scope.dom = dom"div"(
        btn("increment", 1),
        btn("decrement", -1),
        dom"div#count"(string(count[])),
    )

    scope
end

# Display in whatever frontend is avalaible

@sync webio_serve(page("/", req -> counter(1)), 8001)

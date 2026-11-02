const tasklib = require("./tasklib")

export type identity<t...> = {
	__wokedata: (t...) -> (),
}

const module = {
	create = coroutine.running :: <t...>(...never) -> identity<t...>,
	yield = coroutine.yield :: <t...>(ctx: identity<t...>, ...never) -> t...,
	wake = tasklib.spawn :: <t...>(ctx: identity<t...>, t...) -> (),
}

function module.wrap<t...>(fn: (t...) -> ()): identity<t...>
	const function future_yield_loop(...): ()
		fn(...)
		while true do
			fn(coroutine.yield())
		end
	end

	return coroutine.create(future_yield_loop) :: any
end

return table.freeze(module)

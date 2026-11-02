export type EvalMode = "network" | "compiler"

local value: EvalMode = "network"

const eval_mode = {}

function eval_mode.set(mode: EvalMode): ()
	value = mode
end

function eval_mode.get(): EvalMode
	return value
end

return table.freeze(eval_mode)

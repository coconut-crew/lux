const runtime_types = require("./runtime_types")

type rawget_<Indexable, Key> = rawget<Indexable, Key>
type SerDesIO_<Input, Output> = runtime_types.SerDesIO<Input, Output>

type function extract_ser(serdes: type, debug_name: string): type
	const serializer: type = rawget_(serdes, types.singleton("ser"))

	if serializer == types.unknown or serializer == types.singleton(nil) then
		error(`{debug_name} has no serializer`)
	elseif serializer.tag ~= "function" then
		error(
			`{debug_name} has a serializer of type '{serializer.tag}', but we expected the serializer to be of type 'function'`
		)
	end

	const ser_parameters = serializer:parameters().head
	if not ser_parameters then
		error(`{debug_name}'s serializer had no parameters`)
	end
	const ser_ty = ser_parameters[3]
	if not ser_ty then
		error(`{debug_name}'s serializer did not have enough params ({#ser_parameters} / 3)`)
	end

	return ser_ty
end

export type function get_ser_data(serdes: type)
	return extract_ser(serdes, `root`)
end

type function extract_des(serdes: type, debug_name: string): type
	const deserializer: type = rawget_(serdes, types.singleton("des"))

	if deserializer == types.unknown or deserializer == types.singleton(nil) then
		error(`{debug_name} has no deserializer`)
	elseif deserializer.tag ~= "function" then
		error(
			`{debug_name} has a deserializer of type '{deserializer.tag}', but we expected the deserializer to be of type 'function'`
		)
	end

	const des_returns = deserializer:returns().head
	if not des_returns then
		error(`{debug_name}'s deserializer had no returns`)
	end
	const des_ty = des_returns[2]
	if not des_ty then
		error(`{debug_name}'s deserializer did not have enough returns ({#des_returns} / 2)`)
	end

	return des_ty
end

export type function get_des_data(serdes: type)
	return extract_des(serdes, `root`)
end

type function extract_serdes(serdes: type, debug_name: string): (type, type)
	return extract_ser(serdes, debug_name), extract_des(serdes, debug_name)
end

type TStruct_<ValueIn, ValueOut> = runtime_types.SerDesIO<ValueIn, ValueOut> & runtime_types.StructInfo

export type function new_struct(fields: type)
	const ser_table = types.newtable()
	const des_table = types.newtable()

	for field, prop in fields:properties() do
		const serdes = assert(prop.read)

		const ser_ty, des_ty = extract_serdes(serdes, `field {field}`)

		ser_table:setreadproperty(field, ser_ty)
		des_table:setreadproperty(field, des_ty)
	end

	return TStruct_(ser_table, des_table)
end

type AnySerDes = runtime_types.SerDesIO<never, unknown>
type AnyTable = {}

type function extract_dsl_ser(ty: type, path: string): type
	if ty:issubtypeof(AnySerDes) then
		return extract_ser(ty, path)
	elseif ty.tag == "table" then
		const ser_table = types.newtable()

		for field, prop in ty:properties() do
			const read = prop.read
			if not read then
				continue
			end

			const prop_ser = extract_dsl_ser(read, `{path}[{field}]`)
			ser_table:setreadproperty(field, prop_ser)
		end

		const indexer = ty:indexer()
		if indexer then
			const result_ser = extract_dsl_ser(indexer.readresult, `{path}:indexer().readresult`)

			local index = indexer.index
			if indexer.index ~= types.number then
				index = extract_dsl_ser(index, `{path}:indexer().index`)
			end

			ser_table:setindexer(index, result_ser)
		end

		return ser_table
	else
		error(`could not extract DSL serializer for {path} at this time`)
	end
end

type function extract_dsl_des(ty: type, path: string): type
	if ty:issubtypeof(AnySerDes) then
		return extract_des(ty, path)
	elseif ty.tag == "table" then
		const des_table = types.newtable()

		for field, prop in ty:properties() do
			const read = prop.read
			if not read then
				continue
			end

			const prop_des = extract_dsl_des(read, `{path}[{field}]`)
			des_table:setreadproperty(field, prop_des)
		end

		const indexer = ty:indexer()
		if indexer then
			const result_ser = extract_dsl_des(indexer.readresult, `{path}:indexer().readresult`)

			local index = indexer.index
			if indexer.index ~= types.number then
				index = extract_dsl_des(index, `{path}:indexer().index`)
			end

			des_table:setindexer(index, result_ser)
		end

		return des_table
	else
		error(`could not extract DSL deserializer for {path} at this time`)
	end
end

export type function get_dsl_ser_data(ty: type): type
	return extract_dsl_ser(ty, `root`)
end

export type function get_dsl_des_data(ty: type): type
	return extract_dsl_des(ty, `root`)
end

export type function new_dsl(ty: type): type
	const ser_ty, des_ty = extract_dsl_ser(ty, `root`), extract_dsl_des(ty, `root`)

	return SerDesIO_(ser_ty, des_ty)
end

export type function unfreeze(input_table: type): type
	if input_table.tag == "intersection" then
		const new_components = {}

		for i, component in input_table:components() do
			new_components[i] = unfreeze(component)
		end

		return types.intersectionof(table.unpack(new_components))
	elseif input_table.tag == "union" then
		const new_components = {}

		for i, component in input_table:components() do
			new_components[i] = unfreeze(component)
		end

		return types.unionof(table.unpack(new_components))
	elseif input_table.tag == "table" then
		for field, prop in input_table:properties() do
			if not prop.write then
				input_table:setproperty(field, prop.read)
			end
		end

		const write_indexer = input_table:writeindexer()
		if not write_indexer then
			const read_indexer = input_table:readindexer()
			if read_indexer then
				input_table:setindexer(read_indexer.index, read_indexer.result)
			end
		end

		return input_table
	else
		return error(`cannot unfreeze a '{input_table.tag}' type`)
	end
end

return table.freeze({})

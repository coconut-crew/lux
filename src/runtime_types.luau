--- for my sanity
type Ptr = number

export type Des<Output> = (buf: buffer, byte: Ptr) -> (Ptr, Output)
export type Ser<Input> = (buf: buffer, byte: Ptr, data: Input) -> Ptr
export type SerResize<Input> = (buf: buffer, byte: Ptr, data: Input) -> (Ptr, buffer)
export type SerDes<Data> = SerDesIO<Data, Data>
export type SerDesIO<Input, Output> = {
	read bytes_static: number | false,
	read bytes_lowerbound: number,
	read bytes_upperbound: number,
	--- if this is an integer, this is the lowest integral value it represents
	read integral_lowerbound: number?,
	--- if this is an integer, this is the highest integral value it represents
	read integral_upperbound: number?,
	read bytes_sizeof: (Input) -> number,

	read des: Des<Output>,
	read ser: Ser<Input>,
	read ser_resize: SerResize<Input>,
}

--- x: minimum
--- y: maximum
export type Bound = {
	read min: number?,
	read max: number?,
}

export type TBooleanBasic = SerDes<boolean> & {
	read kind: "boolean",
	read subkind: "basic",
}
export type TBooleanSingleton<Value = boolean> = SerDes<Value> & {
	read kind: "boolean",
	read subkind: "singleton",
	read value: boolean & Value,
}
export type TBoolean = TBooleanBasic | TBooleanSingleton

export type TNumberIntegral = SerDes<number> & {
	read kind: "number",
	read subkind: "integral",

	read representation: | "8" | "16" | "24" | "32" | "40" | "48",
	read signed: boolean,
}
export type TNumberVLQ = SerDes<number> & {
	read kind: "number",
	read subkind: "vlq",

	read representation: | "8" | "16" | "24" | "32" | "40" | "48" | "56" | "64",
}
export type TNumberFloat = SerDes<number> & {
	read kind: "number",
	read subkind: "float",

	read representation: "8" | "16" | "32" | "64",
}
export type TNumberSingleton = SerDes<number> & {
	read kind: "number",
	read subkind: "singleton",
	read value: number,
}
-- todo(dev, design, compiler, debug): numeric ranges / modifiers
export type TNumber = TNumberIntegral | TNumberVLQ | TNumberFloat | TNumberSingleton

export type TVectorUniform = SerDes<vector> & {
	read kind: "vector",
	read subkind: "uniform",

	read realized_x: boolean,
	read realized_y: boolean,
	read realized_z: boolean,
	read realized_w: boolean,
	read components: SerDes<number>,
}
export type TVectorXYZW = SerDes<vector> & {
	read kind: "vector",
	read subkind: "xyzw",

	read x: SerDes<number>?,
	read y: SerDes<number>?,
	read z: SerDes<number>?,
	read w: SerDes<number>?,
}
export type TVectorSingleton = SerDes<vector> & {
	read kind: "vector",
	read subkind: "singleton",
	read value: vector,
}
export type TVector = TVectorUniform | TVectorXYZW | TVectorSingleton

export type TStringArbitrary = SerDes<string> & {
	read kind: "string",
	read subkind: "arbitrary",
	read length: SerDes<number>,
}
export type TStringUnion<Members = string> = SerDes<Members> & {
	read kind: "string",
	read subkind: "union",

	read members: { Members },
}
export type TStringSingleton<Value = string> = SerDes<Value> & {
	read kind: "string",
	read subkind: "singleton",
	read value: Value,
}
export type TString<Values = string> = TStringArbitrary | TStringUnion<Values> | TStringSingleton<Values>

export type TBufferArbitrary = SerDes<buffer> & {
	read kind: "buffer",
	read subkind: "arbitrary",
	read length: SerDes<number>,
}
export type TBuffer = TBufferArbitrary

export type TArrayDense<ItemInput = unknown, ItemOutput = ItemInput> = SerDesIO<
	{ read [number]: ItemInput },
	{ read [number]: ItemOutput }
> & {
	read kind: "array",
	read subkind: "dense",

	read length: SerDes<number>,
	read items: SerDesIO<ItemInput, ItemOutput>,
}
export type TArray<Item = unknown> = TArrayDense<Item>

export type TMapSparse<KeyInput = unknown, ValueInput = unknown, KeyOutput = KeyInput, ValueOutput = ValueInput> = SerDesIO<
	{ read [KeyInput]: ValueInput },
	{ read [KeyOutput]: ValueOutput }
> & {
	read kind: "map",
	read subkind: "sparse",
	read length: SerDes<number>,

	read keys: SerDesIO<KeyInput, KeyOutput>,
	read values: SerDesIO<ValueInput, ValueOutput>,
}
export type TMap<Key = unknown, Value = unknown> = TMapSparse<Key, Value>

export type StructInfo = {
	read kind: "struct",
	read subkind: "basic",

	read key_names: { string },
	read key_writers: { SerDes<unknown> },
}
export type TStruct<ValueInput = {}, ValueOutput = ValueInput> = SerDesIO<ValueInput & {}, ValueOutput & {}> & StructInfo

export type TAsync<I = unknown, O = I> = SerDesIO<I, O> & {
	read ready: boolean,
}

export type TType = | TBoolean | TNumber | TVector | TString | TBuffer | TArray | TMap | TStruct | TAsync

return table.freeze({})

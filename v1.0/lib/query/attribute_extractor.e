-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "Extract attribute values from a persistent object, without %
		%creating an Eiffel object. This class is useful when trying to %
		%get parts of on object, whose closure takes long time to retrieve."

class ATTRIBUTE_EXTRACTOR

inherit

	DB_GLOBAL_INFO
	DB_CONSTANTS
	ATTR_TYPER

feature

	last_tuple: ARRAY [ANY]

feature {NONE} -- implementation

	attribute_paths: ARRAY [ATTR_PATH]
			-- paths for the attributes we want

	field_extractors: ARRAY [ATTR_VALUE]
			-- objects to extract field values

feature -- queries for implementing assertions

	paths_defined_and_valid (attribute_names: ARRAY[STRING]): BOOLEAN is
		do
			Result := attribute_paths /= Void and
						attribute_paths.count = attribute_names.count
		end

	field_extractors_defined: BOOLEAN is
		do
			Result := (field_extractors /= Void)
		end

	field_extractor_index_valid (pos: INTEGER): BOOLEAN is
		do
			Result := pos > 0 and pos <= field_extractors.count
		end

feature

	build_extractors (pclass_name: STRING; attribute_names: ARRAY[STRING]) is
		require
			attr_names_ok: attribute_names /= Void and attribute_names.count > 0
			path_array_ok: paths_defined_and_valid (attribute_names)
		local
			i: INTEGER
			extractor: ATTR_VALUE
		do
			-- Create field extractors
			!!field_extractors.make (1, attribute_names.count)
			from i := 1
			until i > attribute_names.count
			loop
				inspect type_of_attr (pclass_name, attribute_paths @ i)
				when Eiffel_string then
					!ATTR_VALUE_STRING!extractor
				when Eiffel_integer then
					!ATTR_VALUE_INTEGER!extractor
				when Eiffel_boolean then
					!ATTR_VALUE_BOOLEAN!extractor
				when Eiffel_char then
					!ATTR_VALUE_CHAR!extractor
				when Eiffel_object then
					!ATTR_VALUE_OBJECT!extractor
				when Eiffel_double then
					!ATTR_VALUE_DOUBLE!extractor
				when Eiffel_pointer then
					!ATTR_VALUE_POINTER!extractor
				else
					except.raise ("Type not supported")
				end;
				field_extractors.put (extractor, i)
				i := i + 1
			end
		end

	force_extractor (new_extractor: ATTR_VALUE; position: INTEGER) is
		require
			extractor_not_void: new_extractor /= Void
			field_extractors_ok: field_extractors_defined
			valid_index: field_extractor_index_valid (position)
		do
			field_extractors.put (new_extractor, position)
		end

	build_paths (attribute_names: ARRAY[STRING]) is
		require
			attr_names_ok: attribute_names /= Void and attribute_names.count > 0
		local
			i: INTEGER
			a_path: ATTR_PATH
		do
			-- Create array of paths
			!!attribute_paths.make (1, attribute_names.count)
			from i := 1
			until i > attribute_names.count
			loop
				!!a_path.make (attribute_names @ i)
				attribute_paths.put (a_path, i)
				i := i + 1
			end
		end

	extract_values (pobject_id: INTEGER) is
		require
			is_persistent: pobject_id /= 0
		local
			i: INTEGER
			value: ANY
		do
			-- Create the output tuple
			from i := 1
			until i > last_tuple.count
			loop
				value := field_extractors.item (i).value_of_attr (pobject_id,
							attribute_paths @ i)
				last_tuple.put (value, i)
				i := i + 1
			end
		end

end -- ATTRIBUTE_EXTRACTOR

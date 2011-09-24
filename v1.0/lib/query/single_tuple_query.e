-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class SINGLE_TUPLE_QUERY [T -> POBJECT]

inherit
	
	ATTRIBUTE_EXTRACTOR

creation

	make

feature

	make (attribute_names: ARRAY[STRING]) is
		require
			attribute_names_ok: (attribute_names /= Void) and then (attribute_names.count > 0)
		do
			field_names := attribute_names
		end

	field_names: ARRAY [STRING]
			-- names of fields in tuples

feature

	execute (list: PLIST [T]; args: ARRAY [ANY]) is
		require
			list_there: list /= Void
		local
			i: INTEGER
			pobject_id: INTEGER
			last_array: ARRAY [ANY]
		do
			if list /= Void then
				if last_result.count > 0 then
					make_attribute_finder_stuff(last_result.i_th_object_id(1)) -- parameter is added
					!!last_tuple.make (1, last_result.count)
				end

				from
					i := 1
				until 
					i > last_result.count
				loop
					pobject_id := last_result.i_th_object_id (i)
					if pobject_id /= 0 then
						last_array := get_attribute_values_persistent (pobject_id)
					else
						last_array := get_attribute_values_non_persistent (last_result.i_th(i))
					end
					last_tuple.put (last_array, i)
					i := i + 1
				end
			else
				-- no result plist
				last_tuple := Void
				debug ("tuple_query")
					io.putstring ("No results for the query:  ")
					io.putstring (where_string)
					io.new_line
				end
			end
		ensure
			has_result: (last_tuple /= Void) implies (last_tuple.count > 0)
			consistent_result: (last_tuple /= Void) implies (last_tuple.count = last_result.count)
			valid_empty: (last_tuple = Void) implies (last_result = Void)
		end


feature {TUPLE_QUERY}-- getting selected fields for one object

	get_attribute_values_non_persistent (object: POBJECT) : ARRAY [ANY] is
		require
			object_exists: object /= Void
		local
			value: ANY
			i: INTEGER
		do
			!!Result.make (1, field_names.count)
			from i := 1
			until i > field_names.count
			loop
				value := field_extractors.item (i).value_of_attr_from_object (object, attribute_paths @ i)
				Result.put (value, i)
				i := i + 1
			end
		ensure 
			good_result: Result /= Void implies Result.count = field_names.count
		end

feature -- made public
	get_attribute_values_persistent (this_pobject_id : INTEGER) : ARRAY [ANY]  is
		require
			is_persistent: this_pobject_id /= 0
		local
			value: ANY
			i: INTEGER
		do
			-- Create the output array
			!!Result.make (1, field_names.count)
			from i := 1
			until i > field_names.count
			loop
				value := field_extractors.item (i).value_of_attr (this_pobject_id, attribute_paths @ i)
				Result.put (value, i)
				i := i + 1
			end
		ensure
			good_result: Result /= Void implies Result.count = field_names.count
		end
	

feature

	init (pobject_id: INTEGER) is
		local
			a_path: ATTR_PATH
			extractor: ATTR_VALUE
			i: INTEGER
			pclass: PCLASS
			-- change went to the parameter
			non_per: ANY
		do		
			pclass := db_interface.find_class_for_object (pobject_id)

			!!attribute_paths.make (1, field_names.count)
			from i := 1
			until i > field_names.count
			loop
				!!a_path.make (field_names @ i)
				attribute_paths.put (a_path, i)
				i := i + 1
			end
			-- Create field extractors
			!!field_extractors.make (1, field_names.count)
			from i := 1
			until i > field_names.count
			loop
				inspect type_of_attr (pclass.name, attribute_paths @ i)
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
				else
					io.putstring ("Eiffel does not support the type ")
					io.putstring (field_names @ i)
					io.putstring (" please re-verify. %N")
					except.raise ("Type not supported")
				end;
				field_extractors.put (extractor, i)
				i := i + 1
			end	
		ensure
			attribute_match: field_names /= Void implies attribute_paths.count = field_names.count
			extractor_match: field_names /= Void implies field_extractors.count = field_names.count
		end

end

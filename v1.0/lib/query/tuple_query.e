-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class TUPLE_QUERY [T -> POBJECT]

inherit
	
	DB_GLOBAL_INFO
	DB_CONSTANTS
	ATTR_TYPER

creation

	make

feature -- creation
	
	make (query_string: STRING) is
			-- create an SQL like db query, where only the selected 
			-- fields are returned.  In the format 
			-- [name,country,country.isn_code] where name like $1 
			-- after the square braces the key word where and then the normal query
		require
			query_string_valid: query_string /= Void
		do
			split_string_up (query_string)
			if where_string /= Void then				
				!!select_query.make (where_string)
			end
		end

	field_names: ARRAY [STRING]
			-- names of fields in tuples


feature -- running queries

	execute (list: PLIST [T]; args: ARRAY [ANY]) is
		require
			list_there: list /= Void
		local
			i: INTEGER
			pobject_id: INTEGER
			last_array: ARRAY [ANY]
		do
			if select_query /= Void then
				select_query.execute (list, args)
				last_result := select_query.last_result
			else
				last_result := list
			end
			if last_result /= Void then
				if last_result.count > 0 then
					make_attribute_finder_stuff
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

	where_string : STRING
			-- the string for the select part of the query

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
	

feature -- results

	last_tuple: ARRAY [ARRAY [ANY]]
			-- result of last query 

	last_result: PLIST [T]
			-- objects from which tuples were extracted 

	error_in_query : BOOLEAN
			-- if query string invalid this becomes true

	
feature {TUPLE_QUERY} -- query control 

	select_query : SELECT_QUERY [T]
	
feature {NONE} -- implementation -- getting_attributes

	attribute_paths: ARRAY [ATTR_PATH]
			-- array of attr_path for getting attributes
	
	field_extractors: ARRAY [ATTR_VALUE]
			-- array of attr_value for getting attributes
	
	make_attribute_finder_stuff is
		require
			last_result /= Void
		local
			a_path: ATTR_PATH
			extractor: ATTR_VALUE
			i: INTEGER
			pclass: PCLASS
			pobject_id: INTEGER
			non_per: ANY
		do		
			pobject_id := last_result.i_th_object_id(1)
			if pobject_id /= 0 then 
				pclass := db_interface.find_class_for_object (pobject_id)
			else
				-- non persistent, !already exists in Eiffel
				non_per := last_result.i_th(1)
				pclass := db_interface.find_class (non_per.generator)
			end
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

feature {NONE} --implementation -- parsing the query string
		
	split_string_up (query_string: STRING) is
		require
			valid_query: query_string /= Void
		local
			lt_index, rt_index, i : INTEGER
		    where_start: INTEGER
			select_string : STRING
		do
			lt_index := query_string.index_of ('[',1)
			if lt_index > 0 then
				rt_index := query_string.index_of (']',lt_index + 1)
			else
				error_in_query := True
				debug ("tuple_query")
					io.putstring (query_string)
					io.putstring (" .. Missing [ in query.%N")
				end
			end
			if not error_in_query and rt_index > 0 then
				where_start := query_string.substring_index ("where", rt_index)
			else	
				debug ("tuple_query")
					io.putstring (query_string)
					io.putstring (" .. Missing ] in query.%N")
				end
				error_in_query := True
			end
			if not error_in_query then
				if where_start > 0 then
					where_string := query_string.substring (where_start + 5, query_string.capacity)
				elseif rt_index + 4 > query_string.capacity then 
					where_string := Void
				else	
					debug ("tuple_query")
						io.putstring (query_string)
						io.putstring (" .. Missing 'where' before select_query statement.%N")
					end
					error_in_query := True	
				end
			end	
			if not error_in_query then
				select_string := query_string.substring (lt_index + 1, rt_index - 1)
				split_select_part (select_string)
			end
		ensure
			valid_query_with_where: not error_in_query implies where_string /= Void 
			valid_query_with_fields: not error_in_query implies field_names /= Void
		end


	split_select_part (select_string: STRING) is
		require 
			valid_select_part: select_string /= Void
		local
			ssp: STRING_SPLITTER
			i: INTEGER
		do
			!!ssp.make_separator (',')
			ssp.split (select_string)
			field_names := ssp.fields
			from
				i := 1
			until
				i > field_names.count
			loop
				(field_names @ i).prune_all(' ')
				i := i + 1
			end
		ensure
			found_field_names: field_names /= Void
		end

end

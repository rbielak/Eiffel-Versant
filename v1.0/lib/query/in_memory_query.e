-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Evaluate query on objects that are in the vstr and in memory
--

class IN_MEMORY_QUERY

inherit

	INTERNAL_QUERY

	VERSANT_EXTERNALS

creation

	make

feature

	make (qi: BYTE_CODE) is
		require
			qi_valid: qi /= Void
		do
			query_interpreter := qi
		end

	first_only: BOOLEAN
			-- if true, return only the first object that fits

	set_first_only (value: BOOLEAN) is
		do
			first_only := value
		end

	typing_criteria: STRING
			-- If set, will only evaluate classes which are exactly of
			-- the `a_class_name' type

	set_typing_criteria (a_class_name: STRING) is
		do
			if typing_criteria /= Void then
				typing_criteria := a_class_name.twin
				typing_criteria.to_upper
			end
		end

	execute (in_list: PLIST [POBJECT]; parameters: ARRAY[ANY]): PLIST [POBJECT] is
			-- execute the query
		local
			i, count: INTEGER
			local_object_id: INTEGER
			object: POBJECT
			done: BOOLEAN
			clname: STRING
			temp: BOOLEAN
			lresult_generator: STRING
		do
			!!in_db_vstr.make (default_pointer)
			-- create the resulting list. It's dynamic type should be 
			-- the same as the input list
			temp := c_check_assert (False)
			lresult_generator := result_generator (in_list.generator)
			lresult_generator.to_upper
			db_interface.ei_class.make_from_name (lresult_generator)
			Result ?= db_interface.ei_class.allocate_object
			Result.make (lresult_generator)
			-- reset assertion flag
			temp := c_check_assert (temp)
			from
				i := 1
				count := in_list.count
				query_interpreter.set_new_parameters (parameters)
				if typing_criteria /= Void then
					clname := typing_criteria.twin
					clname.to_lower
				end
			until
				i > count or done
			loop
				local_object_id := in_list.i_th_object_id (i)
				if local_object_id /= 0 then
					-- Persistent object, see if it's in memory
					object := db_interface.object_table.item (local_object_id)
				else
					-- transient object, not yet stored
					object := in_list.i_th (i)
				end
				if object /= Void then
					if typing_criteria /= Void then
						if object.generator.is_equal (typing_criteria) then
							if query_interpreter.fulfill_criteria (object) then
								Result.extend (object)
								done := first_only
							end
						end
					else
						if query_interpreter.fulfill_criteria (object) then
							Result.extend (object)
							done := first_only
						end
					end
				else
					if typing_criteria /= Void then
						if o_isinstanceof (local_object_id, $(clname.to_c),
									False) then
							in_db_vstr.extend_integer (local_object_id)
						end
					else
						in_db_vstr.extend_integer (local_object_id)
					end
				end
				i := i + 1
			end
			query_interpreter.flush
		ensure then
			-- Result has objects that matched the query
			-- predicates and are in memory
		end

	in_db_vstr: VSTR
			-- vstr of objects that were found not in memory
			-- and will be evaluated in the db

	query_interpreter: BYTE_CODE
			-- Interpreter for in-memory query.

feature {NONE} -- copy pasted from SELECT_QUERY - should be moved into a parent

	extract_generic (gen: STRING): STRING is
		local
			pos: INTEGER
			ex: EXCEPTIONS
		do
			pos := gen.index_of ('[', 1)
			if (pos = 0) or (pos + 1 >= gen.count) then
				!!ex; ex.raise ("Bad generator in a list")
			end
			Result := gen.substring (pos+1, gen.count-1)
		end
	
	result_generator (input_generator: STRING): STRING is
		do
			Result := "PLIST["
			Result.append (extract_generic (input_generator))
			Result.append ("]")
		end


end -- IN_MEMORY_QUERY

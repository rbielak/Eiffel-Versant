-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Query a PLIST of objects
--

class DB_LIST_QUERY [T->POBJECT]

inherit

	DB_QUERY[T]
		redefine
			execute
		end

creation

	make

feature

	list_to_query: like last_result
			-- list to query

	set_list_to_query (new_list: like list_to_query) is
		do
			list_to_query := new_list
		end

	execute is
		do
			debug ("query")
				io.putstring ("db_list_query.execute - list id=")
				io.putint (list_to_query.pobject_id)
				io.putstring (" Size of list_vstr=")
				io.putint (list_to_query.byte_count)
				io.new_line
			end
			last_result := Void
			do_select
			debug ("query")
				io.putstring ("Size of result_vstr=")
				io.putint (result_vstr.byte_count)
				io.putstring (" COntents= ")
				io.putint (result_vstr.i_th_integer (1))
				io.new_line
			end
			if c_get_error = 0 and then result_vstr.exists then
				-- Intersect the result with the list
				if list_to_query.exists then
					debug ("query")
						io.putstring ("Size of list_vstr=")
						io.putint (list_to_query.byte_count)
						io.putstring (" COntents= ")
						io.putint (list_to_query.i_th_object_id (1))
						io.new_line
					end
					result_vstr.intersect_with (list_to_query)
					if c_get_error = 0 and then result_vstr.exists then
						debug ("query")
							io.putstring ("Size of result_vstr=")
							io.putint (result_vstr.byte_count)
							io.putstring (" COntents= ")
							io.putint (result_vstr.i_th_integer (1))
							io.new_line
						end
						!!last_result.make_from_vstr (result_vstr, result_generator)
					end
				end
			else
				debug ("query")
					io.putstring ("Select failed: Error = ")
					io.putint (c_get_error)
					io.new_line
				end
			end
			-- Free up any vstrs
			if predicate_vstr /= default_pointer then
				c_deletevstr (predicate_vstr)
				predicate_vstr := default_pointer
			end
			result_vstr := Void
		end

end -- DB_LIST_QUERY

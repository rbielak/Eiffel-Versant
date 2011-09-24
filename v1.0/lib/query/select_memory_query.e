-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Perform a query on a list of objects
--

class SELECT_MEMORY_QUERY [T]

inherit

	SELECT_ABSTRACT_QUERY [T]
		rename
			build_parser_and_interpreter as make
		redefine
			last_result
		end
	
creation

	make

feature

	set_sorting_criteria (new_criteria: ARRAY[STRING]) is
		do
			sort_criteria := new_criteria
			!!sorter.make (sort_criteria)
		end
	
	get_first (a_list: RLIST [T]; parameters: ARRAY[ANY]): T is
		require else
			query_is_valid: not bad_query
			list_exists: a_list /= void
		local
			timer: TIMER
		do
			debug ("performance")
				io.putstring ("Starting query: ")
				if query_interpreter /= Void then
					query_interpreter.dump
				end
				io.new_line
				!!timer
				timer.start
			end

			last_result := Void

			if a_list.count > 0 then
				execute_it (a_list, parameters, true)
			end

			if last_result /= Void and then last_result.count > 0 then
				Result := last_result.i_th (1)
			end

			debug ("performance")
				timer.stop
				io.putstring (">>>Query took ")
				io.putdouble (timer.seconds_used)
				io.putstring (" seconds.%N")
			end
		end

	execute_it (a_list: RLIST [T]; parameters: ARRAY[ANY]; only_once: BOOLEAN) is
		local
			count, i: INTEGER
			object: T
			done: BOOLEAN
		do
			if query_interpreter /= Void then
				from
					i := 1
					count := a_list.count
					query_interpreter.set_new_parameters (parameters)
					!!last_result.make
				until
					i > count or done
				loop
					object := a_list.i_th (i)
					if object /= Void then
						if query_interpreter.fulfill_criteria (object) then
							last_result.extend (object)
							done := only_once
						end
					end
					i := i + 1
				end
				query_interpreter.flush
			else
				!!last_result.make_and_copy (a_list)
			end
			exec_sort
		rescue
			io.putstring ("Exception when executing query :%N")
			io.putstring (qs)
			io.new_line
		end

	last_result: FAST_RLIST[T]
			-- result of last execution
	
	exec_sort is
		do
			-- Sort the result if needed
			if sorter /= Void and then last_result /= Void then
				sorter.sort_list (last_result)
			end
		ensure
			-- sorted: sort_criteria /= Void implies last_result.is_sorted
		end

feature {NONE}  -- Implementation

	sorter: MEMORY_SORTER [T]

end

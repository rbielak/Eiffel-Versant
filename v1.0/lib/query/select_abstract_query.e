-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Perform a query on a list of objects
--

deferred class SELECT_ABSTRACT_QUERY [T]

inherit

	QUERY_PARSING_AND_INTERPRETING
	
feature

	sort_criteria: ARRAY[STRING]
			-- list of attributes on which to sort

	set_sorting_criteria (new_criteria: ARRAY[STRING]) is
		deferred
		end

	execute (a_list: RLIST [T]; parameters: ARRAY[ANY]) is
		require
			query_is_valid: not bad_query
			list_exists: a_list /= void
		local
			timer: SIMPLE_TIMER
		do
			debug ("query")
				io.putstring ("Starting query: ")
				io.new_line
				io.putstring ("size of input list: ")
				io.putint (a_list.count)
				io.new_line
				!!timer
				timer.start
			end

			last_result := Void

			if a_list.count > 0 then
				execute_it (a_list, parameters, false)
			end

			debug ("query")
				timer.stop
				io.putstring (">>>Query took ")
				io.putdouble (timer.seconds_used)
				io.putstring (" CPU  seconds and ")
				io.putint (timer.elapsed_seconds)
				io.putstring (" elapsed time. %N")
			end
		ensure
			consistent_result: (last_result) /= Void implies (last_result.count > 0)
		end

	execute_it (a_list: RLIST [T]; parameters: ARRAY[ANY]; only_once: BOOLEAN) is
		require
			query_is_valid: not bad_query
			list_exists: a_list /= void
			list_has_elements: a_list.count > 0
		deferred
		end

	get_first (a_list: RLIST [T]; parameters: ARRAY[ANY]): T is
		require else
			query_is_valid: not bad_query
			list_exists: a_list /= void
		deferred
		end

	last_result: RLIST[T]
			-- result of last execution

end

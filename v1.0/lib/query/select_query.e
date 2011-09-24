-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Perform a query on a list of objects
--

class SELECT_QUERY[T->POBJECT]

inherit

	SELECT_ABSTRACT_QUERY [T]
		redefine
			last_result
		end

	DB_GLOBAL_INFO

	DB_CONSTANTS

	QUERY_RESULTS_MANAGER

creation

	make

feature -- Sorting

	set_sorting_criteria (new_criteria: ARRAY[STRING]) is
		do
			sort_criteria := new_criteria
			!!sorter.make (sort_criteria)
		end

feature -- optimization

	set_evaluation_in_client is
			-- Evaluate the query in the client process.
			-- Useful when the list we querying is small,
			-- but there are lots of objects to evaluate
			-- in the database
		do
			evaluation_in_client := True
		end
	
	set_evaluation_in_server is
			-- Evaluate the query in the server process
		do
			evaluation_in_client := False
		end

	set_group_read_result is
		do
			group_read_result := True
		end

feature {MAN_SPEC, DB_INTERNAL} -- secret optimizations for MAN

	set_force_evaluation_in_server (value: BOOLEAN)  is
			-- if you know what you are doing you can try and force 
			-- this query to be evaluated in the server. 
			-- WARNING: If the objects in your query path cross 
			-- databases then the result will be Wrong!!!!
		do
			force_evaluation_in_server := value
		end

	force_evaluation_in_server: BOOLEAN
			-- if all the objects in the path query are in the same 
			-- database we can force the query to be evaluated in the server

feature -- creation

	make (query_string: STRING) is
		require
			query_not_void: query_string /= Void
		do
			build_parser_and_interpreter (query_string)
			if not bad_query then
				if query_interpreter /= Void then
					!!internal_memory_query.make (query_interpreter)
				end
				!!internal_db_path_query
				!!internal_mixed_query
				if parsed_query /= Void then
					!!root_predicate_block.make_as_and
					!!predicate_tree_desc.make (parsed_query, root_predicate_block)
				end
			end
		end

feature -- querying

	get_first (a_list: PLIST [T]; parameters: ARRAY[ANY]): T is
		require else
			query_is_valid: not bad_query
			list_exists: a_list /= void
		local
			timer: SIMPLE_TIMER
		do
			debug ("query")
				io.putstring ("Starting query: ")
				if query_interpreter /= Void then
					query_interpreter.dump
				end
				io.new_line
				io.putstring ("size of input list: ")
				io.putint (a_list.count)
				io.new_line
				!!timer
				timer.start
			end

			last_result := Void

			if a_list.count > 0 then
				execute_it (a_list, parameters, true)
			end

			debug ("query")
				timer.stop
				io.putstring (">>>Query took ")
				io.putdouble (timer.seconds_used)
				io.putstring ("CPU  seconds and ")
				io.putint (timer.elapsed_seconds)
				io.putstring (" elapsed time. %N")
			end

			if last_result /= Void then
				Result := last_result.i_th (1)
			end

		end

feature {SELECT_QUERY}

	execute_it (a_list: PLIST [T]; parameters: ARRAY[ANY]; only_once: BOOLEAN) is
		local
			db_only_vstr, db_result_vstr: VSTR
			query_result: like last_result
			class_to_query: STRING
		do
			if query_interpreter /= Void then
				-- First do in memory query
				internal_memory_query.set_first_only (only_once)
				internal_memory_query.set_typing_criteria (typing_criteria)
				query_result ?= internal_memory_query.execute (a_list, parameters)
				db_only_vstr := internal_memory_query.in_db_vstr

				-- If need only one object and we have
				-- it in memory then we are done
				if not only_once or else query_result.count = 0 then
					if db_only_vstr.exists then
						if typing_criteria = Void then
							class_to_query := extract_generic (a_list.generator)
						else
							class_to_query := typing_criteria
						end
						db_result_vstr := exec_db_query (db_only_vstr, parameters, class_to_query)
						!!last_result.make_from_vstr (db_result_vstr, 
													  result_generator (a_list.generator))
						last_result.union_with (query_result)
						db_result_vstr.dispose_area
					end
				end
				if last_result = Void then
					last_result := query_result
				end
				db_only_vstr.dispose_area
			else
				last_result := a_list.twin
			end
			-- Create a final result
			if (last_result /= Void) and then (last_result.count > 0) then
				all_results.put (last_result, last_result.object_id)
				last_result.set_parent_container (a_list.parent_container)
			else
				last_result := Void
			end
			exec_sort
		end

	root_predicate_block: DB_QUERY_PREDICATE_BLOCK
			-- predicate block at the top of the predicate tree

	predicate_tree_desc: PREDICATE_TREE_DESC
			-- associates arguments and predicates in the
			-- query expression tree

	exec_db_query (a_list_vstr: VSTR; parameters: ARRAY[ANY];
						class_name: STRING): VSTR is
			-- Execute the query on the list with the specified paramaters.
		require
			query_is_valid: not bad_query
			list_exists: a_list_vstr /= Void and then a_list_vstr.exists
		local
			retry_mixed_query: BOOLEAN
			weak_link_failure: BOOLEAN
			first_object_id, class_id: INTEGER
			pclass: PCLASS
		do
			-- Connect the arguments with their predicates
			-- Get the PCLASS from the first object in the vstr
			-- Note: Any attributes named in the query MUST be present in every
			-- object in the input Vstr, so it doesn't matter which PCLASS we use
			first_object_id := a_list_vstr.i_th_integer (1)
			class_id := db_interface.o_classobjof (first_object_id)
			pclass := db_interface.find_class_by_class_id (class_id)
			predicate_tree_desc.prepare_predicate (parameters, pclass)
			debug ("query")
				if evaluation_in_client then
					io.putstring ("forced evaluation_in_client%N")
				elseif retry_mixed_query then
					io.putstring ("retry after an exception%N")						
				elseif root_predicate_block.has_special_predicates then
					io.putstring (" Special predicates%N")
				else
					io.putstring ("Evaluation in server %N")
				end
			end
			-- Execute the query
			if force_evaluation_in_server or else
				not (evaluation_in_client or retry_mixed_query or
					 root_predicate_block.has_special_predicates) then
					internal_db_path_query.set_class_name (db_interface.view_table.versant_class (class_name))
					internal_db_path_query.set_group_read_result (group_read_result)
					internal_db_path_query.set_predicate_block (root_predicate_block)
					internal_db_path_query.set_database (fixed_database_to_query)
					Result := internal_db_path_query.execute (a_list_vstr, parameters)
					-- perhaps limit the query to one db here...
			else
				internal_mixed_query.set_class_name (
						db_interface.view_table.versant_class (class_name))
				internal_db_path_query.set_group_read_result (group_read_result)
				internal_mixed_query.set_predicate_block (root_predicate_block)
				internal_mixed_query.set_database (fixed_database_to_query)
				Result := internal_mixed_query.execute (a_list_vstr, parameters)
			end
				-- Make sure we don't keep references to persistent parameters
			predicate_tree_desc.flush
		rescue
			-- If there is a problem with the path
			-- predicates, do the query in a different way
			if (db_interface.last_error = db_interface.path_select_multi_db_error)
					and not retry_mixed_query then
				retry_mixed_query := True
				debug ("query")
					io.putstring ("select_query - retrying after exception....%N")
				end
				-- Don't bother with the server after this time
				evaluation_in_client := True
				retry
			elseif (db_interface.last_error = db_interface.weak_link_query_error)
					and not retry_mixed_query then
				-- Failed because a query on a weak-link was attempted. Retry a
				-- different strategy
				retry_mixed_query := True
				weak_link_failure := True
				retry
			end
		end

	exec_sort is
		do
			-- Sort the result if needed
			if sorter /= Void and then last_result /= Void then
				debug ("query")
					print ("SELECT_QUERY - sorting result%N")
				end
				sorter.sort_list (last_result)
			end
		ensure
			-- sorted: sort_criteria /= Void implies last_result.is_sorted
		end


feature

	last_result: PLIST[T]
			-- result of last execution

	set_fixed_database (a_db: DATABASE) is
		do
			fixed_database_to_query := a_db
		end

	reset_last_result is
		do
			last_result := Void
		end

	set_typing_criteria (a_class_name: STRING) is
		do
			typing_criteria := a_class_name
		end

feature {NONE}  -- Implementation

	evaluation_in_client: BOOLEAN
			-- if true, don't let the server evaluate the
			-- query do it all in the client

	group_read_result: BOOLEAN

	fixed_database_to_query: DATABASE

	typing_criteria: STRING
			-- If set, will only evaluate classes which are exactly of
			-- the `a_class_name' type

	internal_memory_query: IN_MEMORY_QUERY
			-- in memory query

	internal_db_path_query: IN_DB_PATH_QUERY
			-- query done in server

	internal_mixed_query: MIXED_PATH_QUERY

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

	sorter: SORTER [T]

end -- SELECT_QUERY

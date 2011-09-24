-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Query on a class of objects
--

class CLASS_SELECT_QUERY [T -> POBJECT]

inherit
	
	DB_GLOBAL_INFO

	DB_CONSTANTS

	QUERY_RESULTS_MANAGER

	QUERY_PARSING_AND_INTERPRETING

creation
	
	make

feature
	
	make (query_string: STRING) is
		require
			query_not_void : query_string /= Void
		do
			build_parser_only (query_string)
			if not bad_query then
				!!internal_class_query.make ("")
				if parsed_query /= Void then
					!!root_predicate_block.make_as_and
					!!predicate_tree_desc.make (parsed_query, root_predicate_block)
				end
			end
		end
	
	last_result: PLIST [T]
			-- Result of the last query
	
	class_name: STRING
			-- class to query
	
	set_class_name (new_class_name: STRING) is
			-- Set the name of the class to query
		require
			new_class_name /= Void
		do
			class_name := new_class_name.twin
			class_name.to_lower
		end
	
	database: DATABASE
			-- database to query
	
	set_database (db: DATABASE) is
			-- set database
		do
			database := db
		end

	execute (parameters: ARRAY [ANY]) is
		require
			query_parsed: not bad_query
			class_specified: class_name /= Void
			database_specified: database /= Void
		local
			class_id: INTEGER
			pclass: PCLASS
			timer: TIMER
			all_instances, result_vstr: VSTR
		do
			debug ("query")
				io.putstring ("Starting CLASS query: ")
				if parsed_query /= Void then
					io.putstring (parsed_query.out)
				end
				!!timer
				timer.start
			end
			last_result := Void
			-- Find PCLASS for the query
			if database = Void then
				class_id := db_interface.current_database.find_class_id (class_name)
			else
				class_id := database.find_class_id (class_name)
			end
			pclass := db_interface.find_class_by_class_id (class_id)

			predicate_tree_desc.prepare_predicate (parameters, pclass)

			if root_predicate_block.has_special_predicates then
				-- must retrieve all instances into a vstr
				all_instances := pclass.all_instances (True)
				if all_instances /= Void then
					result_vstr := root_predicate_block.evaluate_block (all_instances)
					if result_vstr.integer_count /= 0 then
						!!last_result.make_from_vstr (result_vstr, result_generator)
					end
				else
					last_result := Void
				end
			else
				internal_class_query.set_database (database)
				internal_class_query.set_predicate_block (root_predicate_block)
				internal_class_query.set_class_name (class_name);
				internal_class_query.execute
				last_result := internal_class_query.last_result
			end
			-- 
			if last_result /= Void then
				all_results.put (last_result, last_result.object_id)
			end
			debug ("query")
				timer.stop
				io.putstring (">>>Query took ")
				timer.print_time
			end
		ensure
			consistent_result: (last_result /= Void) implies (last_result.count > 0)
		end

feature {NONE}	
	
	root_predicate_block: DB_QUERY_PREDICATE_BLOCK
			-- predicate block at the top of the predicate tree
	
	predicate_tree_desc: PREDICATE_TREE_DESC
			-- associates arguments and predicates in the
			-- query expression tree
	
	internal_class_query: DB_CLASS_QUERY [T]
			-- query to execute

	result_generator: STRING is
			-- generator for the Result
		do
			Result := "PLIST["
			Result.append (class_name)
			Result.append ("]")
			Result.to_upper
		end
	
end -- CLASS_SELECT_QUERY

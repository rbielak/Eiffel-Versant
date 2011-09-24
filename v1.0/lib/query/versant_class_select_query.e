-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Query on a class of objects -- Result is stored in a VSTR
--

class VERSANT_CLASS_SELECT_QUERY

inherit
	
	DB_GLOBAL_INFO

	DB_CONSTANTS

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
	
	last_result: VSTR
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
			timer: SIMPLE_TIMER
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
				except.raise ("Cannot handle special predicates")
			end
			internal_class_query.set_database (database)
			internal_class_query.set_predicate_block (root_predicate_block)
			internal_class_query.set_class_name (class_name);
			internal_class_query.execute
			last_result := internal_class_query.last_result
			-- 
			debug ("query")
				timer.stop
				io.putstring (">>>Query took ")
				timer.print_time
			end
		ensure
			consistent_result: (last_result /= Void) implies (last_result.integer_count > 0)
		end

feature {NONE}	

	root_predicate_block: DB_QUERY_PREDICATE_BLOCK
			-- predicate block at the top of the predicate tree

	predicate_tree_desc: PREDICATE_TREE_DESC
			-- associates arguments and predicates in the
			-- query expression tree

	internal_class_query: VERSANT_DB_CLASS_QUERY
			-- query to execute
	
end -- VERSANT_CLASS_SELECT_QUERY

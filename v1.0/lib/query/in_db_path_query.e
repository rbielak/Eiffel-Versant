-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- In database query, presuming all paths work OK.
--

class IN_DB_PATH_QUERY

inherit

	INTERNAL_QUERY

	MEMORY

feature {SELECT_QUERY}

	group_read_result: BOOLEAN

	set_group_read_result (bool: BOOLEAN) is
		do
			group_read_result := bool
		end

	class_name: STRING 
			-- class to query on

	set_class_name (new_name: STRING) is
		do
			class_name := new_name.twin
			class_name.to_lower
		end

	database: DATABASE
			-- if not Void, query only this database

	set_database (db: DATABASE) is
		do
			database := db
		end

	execute (in_vstr: VSTR; parms: ARRAY [ANY]): VSTR is
		require else
			root_predicate_block /= Void
		local
			result_so_far: VSTR
			db: DATABASE
			gc_was_on: BOOLEAN
			predicate_block_ptr: POINTER
			i: INTEGER
			err: INTEGER
		do
			debug ("query")
				io.putstring ("in_db_path_query on class: ")
				if class_name /= Void then
					io.putstring (class_name)
				else
					io.putstring ("<unknown>")
				end
				io.new_line
			end

			-- disable GC while doing query, so that objects don't get moved
			if collecting then
				collection_off
				gc_was_on := True
			end

			if root_predicate_block /= Void then
				predicate_block_ptr := root_predicate_block.to_pointer
			else
				predicate_block_ptr := default_pointer
			end

			if database /= Void then
				!!Result.make (database.db_class_select (class_name,
								predicate_block_ptr))
				if Result.exists and group_read_result then
io.putstring ("Group reading ");io.putint (Result.integer_count);io.putstring (" objects%N")
					err := db_interface.o_greadobjs (Result.area, $(database.name.to_c), False, 0)
				end
			else
				-- Issue select on each database we are connected to 
				!!Result.make (default_pointer)
				from
					i := 1
				until
					i > db_interface.active_databases.count
				loop
					db := db_interface.active_databases.i_th (i)
					!!result_so_far.make (db.db_class_select (class_name,
								predicate_block_ptr))
					-- Append vstrs
					if result_so_far.exists then
						if group_read_result then
io.putstring ("Group reading ");io.putint (result_so_far.integer_count);io.putstring (" objects%N")
							err := db_interface.o_greadobjs (result_so_far.area, $(db.name.to_c), False, 0)
						end
						Result.concat_area (result_so_far)
						result_so_far.dispose_area
					end
					i := i + 1
				end
			end
			if Result.exists then
				Result.intersect_with (in_vstr)
			end
			if gc_was_on then
				collection_on
			end
		end

	set_predicate_block (new_block: DB_QUERY_PREDICATE_BLOCK) is
		do
			root_predicate_block := new_block
		end

	root_predicate_block: DB_QUERY_PREDICATE_BLOCK
			-- pointer to top level predicate

end -- IN_DB_PATH_QUERY

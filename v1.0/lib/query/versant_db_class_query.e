-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Query on a class of objects -- Result is a VSTR
--

class VERSANT_DB_CLASS_QUERY

inherit

	VERSANT_DB_PATH_QUERY

creation

	make

feature

	class_name: STRING 
			-- class to query on

	set_class_name (new_name: STRING) is
		do
			class_name := new_name
		end

	execute is
		require else
			class_name /= Void
		do
			last_result := do_class_select
		end

feature

	make (new_class_name: STRING) is
			-- Create a query object
		do
			class_name := new_class_name.twin
		end

	do_class_select: VSTR is
		local
			result_so_far: VSTR
			db: DATABASE
			gc_was_on: BOOLEAN
			i: INTEGER
		do
			-- disable GC while doing query, so that objects don't get moved
			if collecting then
				collection_off;
				gc_was_on := True
			end

			if predicate_block /= Void then
				predicate_block_ptr := predicate_block.to_pointer
			else
				predicate_block_ptr := default_pointer
			end

			if database /= Void then
				!!Result.make (database.db_class_select (
								class_name, predicate_block_ptr))
			else
				-- Issue select on each database we are connected to 
				!!Result.make (default_pointer)
				from 
					i := 1
				until 
					i > db_interface.active_databases.count
				loop
					db := db_interface.active_databases.i_th (i)
					!!result_so_far.make (db.db_class_select (
								class_name, predicate_block_ptr))
					-- Append vstrs
					if result_so_far.exists then
						Result.concat_area (result_so_far)
						check_error
						result_so_far := Void
					end
					i := i + 1
				end
			end
			if gc_was_on then
				collection_on
			end
		rescue
			-- in case of exception enable GC 
			if gc_was_on then
				collection_on
			end
		end

invariant

	class_name /= Void

end -- VERSANT_DB_CLASS_QUERY

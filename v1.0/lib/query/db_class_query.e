-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Query on a class of objects
--

class DB_CLASS_QUERY [T -> POBJECT]

inherit

	DB_PATH_QUERY [T]
	
creation
	
	make

feature
	
	
	class_name: STRING 
			-- class to query on
	
	
	set_class_name (new_name: STRING) is
		require
			new_name /= Void
		do
			class_name := new_name.twin
			class_name.to_lower
		end
	
	execute is
		require else
			class_name /= Void
		local
			result_vstr: VSTR
		do
			last_result := Void
			result_vstr := do_class_select
			-- Create a result array
			if result_vstr.exists then
				!!last_result.make_from_vstr (result_vstr, result_generator)
			end
		end


feature {NONE}

	make (new_class_name: STRING) is
			-- Create a query object
		require
			new_class_name /= Void
		do
			class_name := new_class_name.twin
			class_name.to_lower
		end
	
	result_generator: STRING is
			-- generator for the Result
		do
			Result := "PLIST["
			Result.append (class_name)
			Result.append ("]")
			Result.to_upper
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

end -- DB_CLASS_QUERY

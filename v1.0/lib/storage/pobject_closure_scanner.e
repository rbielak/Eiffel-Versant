-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Class to compute referencial closures of POBJECT structures
--

class POBJECT_CLOSURE_SCANNER
	
creation 
	
	make

feature
	
	
	closure : TWO_WAY_LIST [POBJECT]
			-- Closure computed by traversse
	
	
	wipe_out_closure is
		do
			from closure.start
			until closure.off
			loop
				closure.item.set_closure_position (0)
				closure.forth
			end
			closure.wipe_out
		end

	traverse (object : POBJECT; action : POBJECT_ACTION_COMMAND) is
			-- Traverse through objects in memory and in
			-- the database
		require
			object_there: object /= Void
			list_empty: closure.count = 0
		local
			i : INTEGER
			current_object, one_object : POBJECT
		do
			-- Perform the actionon the first object
			action.execute (closure, object)
			-- Then scan for more
			from
				-- put root object in the closure
				closure.start
			until
				closure.off
			loop
				current_object := closure.item;
				if (current_object /= Void) then
					-- Scan through reference
					-- attributes of current_object
					from i := 1
					until i > current_object.ref_count
					loop
						one_object := current_object.ith_ref (i)
						if (one_object /= Void) and then 
							(one_object.closure_position = 0) 
						 then
							action.execute (closure, one_object);
						end
						i := i + 1
					end
				end
				closure.forth
			end
		end
	
	traverse_mem (object : POBJECT; action : POBJECT_ACTION_COMMAND) is
			-- Traverse through objects already in memory
		local
			except : expanded EXCEPTIONS
		do
			except.raise ("Not implemented yet")
		end
	
feature {NONE}
	
	make is
		do
			!!closure.make
		end


end -- POBJECT_CLOSURE_SCAN

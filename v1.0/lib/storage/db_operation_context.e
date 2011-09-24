-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Context for each database operation 
--

class DB_OPERATION_CONTEXT

creation
	
	make_for_retrieve,
	make_for_store_new,
	make_for_store_difference,
	make_for_store

feature {NONE}
	
	
	make_for_retrieve, make_for_store is
		do
			!!objects_in_progress.make (500)
		end
	
	make_for_store_new is
		do
			make_for_retrieve
			!!new_objects.make (100)
			!!old_objects.make (100)
		end
	
	make_for_store_difference is
		do
			make_for_store
			!!diff_stack.make (200)
		end
	
feature {POBJECT}

	new_objects : SE_STACK[POBJECT];
			-- New objects found during "store_new"
	
	old_objects : SE_STACK[POBJECT];
			-- Old objects found during "store_new" hat
			-- depend on the new objects and have to be stored

	objects_in_progress : SE_STACK[POBJECT];
			-- Objects affected by the latest db operation

	
	
feature {PERSISTENT_ROOTS, POBJECT, DB_INTERNAL}

	diff_stack: SE_STACK [POBJECT]
			-- stack of objects that were found different
			-- during "check_difference" or "store_difference"
	
feature {DB_GLOBAL_INFO, DB_INTERFACE_INFO}
	
	clean_up_on_abort is
			-- In case of transaction abort clean up
		local
			object: POBJECT
		do
			from 
			until 
				objects_in_progress.empty 
			loop
				object := objects_in_progress.item;
				check
					is_in_progress: object.db_operation_in_progress
				end;
				object.mark_not_in_progress;
				objects_in_progress.remove
			end
		end

	mark_objects_not_in_progress is
			-- Mark objects not in progress
		local
			object : POBJECT
		do
			from
			until 
				objects_in_progress.empty 
			loop
				object := objects_in_progress.item;
				check
					is_in_progress: object.db_operation_in_progress
				end;
				object.mark_not_in_progress;
				objects_in_progress.remove
			end
		ensure
			objects_in_progress.empty
		end;
	

end -- DB_OPERATION_CONTEXT

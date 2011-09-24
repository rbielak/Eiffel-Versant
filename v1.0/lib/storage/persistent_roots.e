-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--

class PERSISTENT_ROOTS
	
inherit 

	DB_GLOBAL_INFO
	
	SHARED_PRIMARY_CONTAINER

feature {NONE}
	
--	current_rights_list : LINKED_LIST [DATABASE_RIGHTS_SET] is
			-- User's access rights to the roots
--		once
--			!!Result.make
--		end

	roots: INDEXED_LIST [PERSISTENCY_ROOT [POBJECT], STRING] is
			-- List of all roots accessed by the application
		once
			!!Result.make (100)
		end

feature {DB_INTERFACE_INFO}
 
	flush_all_roots is
		do
			from
				roots.start
			until
				roots.off
			loop
				roots.item.flush
				roots.forth
			end
			default_container.memory_items.clear_all
		end

feature

	set_rights_list (new_list: DATABASE_RIGHTS_SET) is
		require
			list_ok: new_list /= Void
		local
			db_table : ACTIVE_DB_TABLE
			one_db_right : DATABASE_RIGHTS
			one_db : DATABASE
			i : INTEGER
		do
--			current_rights_list.put (new_list);
			-- Re-compute rights stamps for each database connected
			db_table := db_interface.active_databases
			from 
				i := 1
			until 
				i > db_table.count
			loop
				-- Index by "i_th" is slower, but it
				-- preservers the cursor for others
				one_db := db_table.i_th(i)
				one_db_right := new_list.rights_for_database (one_db.name_without_server)
				one_db.compute_rights_stamps (one_db_right.rights);
				i := i + 1
			end
			-- Now go through all the existing roots and
			-- retrieve their rights stamps
--			from roots.start
--			until roots.off
--			loop
--				one_root := roots.item;
--				one_root.reset_stamp
--				roots.forth
--			end
			reset_roots_rights_stamps
		end

	update_rights_list (rights_list: DATABASE_RIGHTS_SET) is
		require
			list_ok: rights_list /= Void
		local
			i: INTEGER
			db_table : ACTIVE_DB_TABLE
			one_db_right : DATABASE_RIGHTS
			one_db : DATABASE
		do
			-- Re-compute rights stamps for each database connected
			db_table := db_interface.active_databases
			from 
				i := 1
			until 
				i > db_table.count
			loop
				-- Index by "i_th" is slower, but it
				-- preservers the cursor for others
				one_db := db_table.i_th(i)
				one_db_right := rights_list.rights_for_database (one_db.name_without_server)
				if one_db_right /= Void then
					one_db.update_rights_stamps (one_db_right.rights);
				end
				i := i + 1
			end
			-- Now go through all the existing roots and
			-- retrieve their rights stamps
--			from roots.start
--			until roots.off
--			loop
--				one_root := roots.item;
--				one_root.reset_stamp
--				roots.forth
--			end
			reset_roots_rights_stamps
		end


	register (root_obj: PERSISTENCY_ROOT [POBJECT]) is
		require
			has_root_obj: root_obj /= void
		local
			r_stamp : INTEGER;
		do
			if not roots.has_key (root_obj.root_name) then
				roots.put_key (root_obj, root_obj.root_name)
				-- find the roots rights
				r_stamp := root_obj.root_database.rights_stamp_by_id (root_obj.root_id);
				root_obj.set_rights_stamp (r_stamp);
			end
		end
	

	store_differences is
			-- Store objects that are different in Eiffel.
		local
			diffs : LIST[POBJECT];
			set_implicit_commit : BOOLEAN;
			found_mismatch: BOOLEAN
			context: DB_OPERATION_CONTEXT
			it: POBJECT
			handler: DEFAULT_VERSION_MISMATCH_HANDLER
		do
			-- Empty out the list for version-mismatched objects
			db_interface.reset_mismatch_list
			io.putstring ("Store differences - start %N");
			-- Find differences
			diffs := check_all;
			db_interface.start_transaction
			if (diffs /= Void) and then (diffs.count > 0) then
				!!context.make_for_store_difference
				db_interface.operation_context_stack.put (context)
				io.putstring (">>> There were ");
				io.putint (diffs.count);
				io.putstring (" different objects...%N")
				-- Write lock all objects in the list,
				-- before we attempt to write
				from diffs.start
				until diffs.off
				loop
					it := diffs.item
					-- If object is not yet persistent, then make it so
					if it.pobject_id = 0 then
						it.make_persistent
					elseif it.write_allowed then
						-- Otherwise write lock it, if we can write it
						db_interface.lock_object (it.pobject_id,
								db_interface.db_write_lock)
					end
					diffs.forth
				end
				-- Check for version differences
				from diffs.start
				until diffs.off
				loop
					it := diffs.item
					-- Only check objects we can write. Read-only different
					-- objects are ignored
					if it.write_allowed and then 
						(it.pobject_version /= it.cache_version) then
						-- Add the object to a global mismatch list
						found_mismatch := True
						db_interface.mismatch_list.extend (diffs.item)
					end
					diffs.forth
				end
				if found_mismatch then
					!!handler
					-- display some info about the mismatched objects 
					-- before crashing
					from db_interface.mismatch_list.start
					until db_interface.mismatch_list.off
					loop
						if handler.handle (db_interface.mismatch_list.item) then
						end
						db_interface.mismatch_list.forth
					end
					-- Mistmatches found raise and exception
					except.raise ("Version mismatch")
				end
				-- Now shallow store the objects
				io.putstring ("--> Storing ");
				io.putint (diffs.count);
				io.putstring (" objects. %N");
				from diffs.start
				until diffs.off
				loop
					debug ("store_diff")
						io.putstring ("---> Storing object of type <");
						io.putstring (diffs.item.generator);
						io.putstring ("> %N");
					end
					if diffs.item.write_allowed then
						diffs.item.store_shallow_obj (context)
						-- diffs.item.store_shallow
					else
						io.putstring ("WARNING: skiping past a read_only object. Type: ")
						io.putstring (diffs.item.generator)
						if diffs.item.pobject_id /= 0 then
							io.putstring ("  LOID=")
							io.putstring (diffs.item.external_object_id)
						end
						io.putstring (" stamp: ")
						io.putint (diffs.item.rights_stamp)
						io.new_line
 					end
					diffs.forth
				end;
	 			context.mark_objects_not_in_progress
				db_interface.operation_context_stack.remove 
			end;
			db_interface.end_transaction
			io.putstring ("Store differences - end%N");
		end;
	
	check_all : LIST [POBJECT] is
			-- Return a list of object that are different
		local
			obj : POBJECT;
			diff_count : INTEGER;
			diff_stack : SE_STACK [POBJECT]
			context: DB_OPERATION_CONTEXT
			timer: SIMPLE_TIMER
		do
			if roots.count > 0 then
				debug ("store_difference_speed")
					!!timer
				end
				db_interface.start_transaction
				-- Create a result list
				!TWO_WAY_LIST[POBJECT]!Result.make;
				!!roots_with_diffs.make;
				!!context.make_for_store_difference
				db_interface.operation_context_stack.put (context)
				-- Find the differences
				from
					roots.start;
					diff_stack := context.diff_stack
				until
					roots.off
				loop
					debug ("store_difference_speed")
						timer.start
					end
					debug ("diff_scanner_all")
						io.putstring ("Diffing root: ");
						io.putstring (roots.item.root_name);
						io.new_line;
					end;
					if not roots.item.available then
						io.putstring ("Warning: root: ")
						io.putstring (roots.item.root_name)
						io.putstring (" not available - (db disconnected) %N")
					else
						db_interface.set_current_root_id (roots.item.root_id)
						db_interface.set_current_database (roots.item.root_database)
						-- Only check the roots to which we cam write
						if roots.item.write_allowed then
							roots.item.check_diff_obj (False, context);
						end
						db_interface.unset_current_root_id;
						db_interface.unset_current_database
						if diff_stack.count > 0 then
							roots_with_diffs.extend (roots.item);
							io.putstring ("Root: ");
							io.putstring (roots.item.root_name); 
							io.putstring (" had ");
							io.putint (diff_stack.count); 
							io.new_line;
						end;
						-- empty the stack onto the result list
						from
						until diff_stack.empty
						loop
							if (diff_stack.item.pobject_class = Void) then
								db_interface.force_class_on_new_object (diff_stack.item, 
																		roots.item.root_database)
							end
							Result.extend (diff_stack.item);
							diff_stack.remove
						end
					end
					debug ("store_difference_speed")
						timer.stop
						if timer.elapsed_seconds > 2 then
							print (roots.item.root_name)
							print (": ")
							timer.print_time
						end
					end
					roots.forth
				end; -- loop
				-- Mark all scanned objects as done
				context.mark_objects_not_in_progress
				db_interface.operation_context_stack.remove
				-- Commit to release any locks that may have been
				-- taken out
				db_interface.end_transaction
			end
		end;
	
	refresh_all is
			-- Refresh all im memory objects from the database
		local
			context: DB_OPERATION_CONTEXT
		do
			if roots.count > 0 then
				!!context.make_for_retrieve
				db_interface.operation_context_stack.put (context)
				-- Refresh all roots
				from
					roots.start
				until
					roots.off
				loop
					roots.item.refresh_obj (context)
					roots.forth;
				end;
				context.mark_objects_not_in_progress
				db_interface.operation_context_stack.remove
			end
		end

feature {NONE}	

	reset_roots_rights_stamps is
		do
			-- Now go through all the existing roots and
			-- retrieve their rights stamps
			from roots.start
			until roots.off
			loop
				roots.item.reset_stamp
				roots.forth
			end
		end
	
	roots_with_diffs : LINKED_LIST [PERSISTENCY_ROOT [POBJECT]];
	
	lock_roots_with_diffs (write_lock : BOOLEAN) is
			-- If "write_lock" is true then upgrade all
			-- locks to wrire_locks, if false then upgrade
			-- "no_locks" to "read_locks" (write_locks remain)
		obsolete "Does anyone call this routine?"
		local
			one_root : PERSISTENCY_ROOT [POBJECT]
		do
			if roots.count > 0 then
				from roots_with_diffs.start
				until roots_with_diffs.off
				loop
					one_root := roots_with_diffs.item;
					if one_root.contents.has_write_lock then
						-- it's already locked, don't do anything
					elseif write_lock then
						-- upgrade to write_lock
						one_root.contents.write_lock_list
					else -- just get a read lock
						if not one_root.contents.has_read_lock then
							one_root.contents.read_lock_list
						end
					end
					roots_with_diffs.forth;
				end;
			end
		rescue
			io.putstring ("ERROR: crashed while locking: ")
			if one_root /= Void then
				io.putstring (one_root.root_name)
			else
				io.putstring (" nothing! ")
			end
			io.new_line
		end
	

end -- persistent_roots

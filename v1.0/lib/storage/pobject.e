-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- POBJECT - parent of all persistent objects 
--
class POBJECT
	
inherit

	DB_GLOBAL_INFO
		redefine 
			copy, is_equal
		end;
	
	PUBLISHER
		redefine
			copy, is_equal
		end
	
	IDENTIFIED
		rename
			copy as identified_copy,
			is_equal as identified_is_equal
		redefine
			dispose
		end
	
	IDENTIFIED
		redefine
			copy, is_equal, dispose
		select
			copy, is_equal
		end;
	
	STAMPED
		rename
			write_allowed as stamped_write_allowed,
			root_id as pobject_root_id
		undefine
			copy, is_equal
		end
	
	STAMPED
		rename
			root_id as pobject_root_id			
		undefine
			copy, is_equal
		redefine
			write_allowed
		select
			write_allowed
		end

feature -- object ID and Version
	
	pobject_id : INTEGER;
			-- object id of this object
	
	external_object_id : STRING is
			-- External form of object ID
		require
			is_persistent: pobject_id /= 0
		do
			Result := db_interface.c_get_loid (pobject_id)
		ensure
			Result /= Void
		end;
	
	pobject_version : INTEGER;
			-- version of this object
	
	pobject_root_id : INTEGER
			-- ID of the persistent root I belong to (0 if none)
	
	pobject_class : PCLASS;
			-- class to which I belong

	database : DATABASE is
			-- This object's database
		require else
			is_persistent : pobject_id /= 0
		do
			if pobject_class /= Void then
				Result := pobject_class.db
			end
		end

feature -- Stamping
	
	reset_stamp is
			-- Reset the stamp of the object according to
			-- the current user rights
		local
			context: DB_OPERATION_CONTEXT
		do
			!!context.make_for_retrieve
			db_interface.operation_context_stack.put (context)
			reset_stamp_obj (context)
			context.mark_objects_not_in_progress 
			db_interface.operation_context_stack.remove			
		ensure
			no_db_action_in_progress: not db_operation_in_progress
		end;

feature -- event notification

	was_modified: BOOLEAN is
			-- returns True if the object was modified in the 
			-- database by another user
		local
			obj_ptr: POINTER
		do
			if pobject_id /= 0 then
				obj_ptr := db_interface.c_ptrfromcod (pobject_id)
				Result := db_interface.c_was_modified (obj_ptr)
			end
		end

feature {DB_EVENT_QUEUE}

	mark_modified is
			-- Set the "mark" modified flag to true
		require
			pobject_id /= 0
		local
			obj_ptr: POINTER
		do
			obj_ptr := db_interface.c_ptrfromcod (pobject_id)
			db_interface.c_set_was_modified (obj_ptr)
			publish (Void)
		end

feature -- Storing

	write_allowed : BOOLEAN is
			-- True if we can write this object to the database
		do
			if pobject_id /= 0 then
				Result := stamped_write_allowed 
			else
				Result := true
			end
		end

	store is
			-- Store object's attributes in the database
			-- (deep storage)		
		local
			reset_root_id, reset_db : BOOLEAN
			context: DB_OPERATION_CONTEXT
		do
			!!context.make_for_store
			db_interface.operation_context_stack.put (context)
			db_interface.version_mismatch_handler.prepare
			db_interface.reset_mismatch_list
			if db_interface.current_root_id = 0 then
				reset_root_id := True
				db_interface.set_current_root_id (pobject_root_id)
			end
			if (pobject_id /= 0) and then (database /= Void) then
				db_interface.set_current_database (database)
				reset_db := True
			end
			debug ("pobject")
				io.putstring ("Storing type: ");
				io.putstring (generator);
				io.new_line;
			end;
			store_obj (context);
			context.mark_objects_not_in_progress
			if db_interface.transaction_level = 0 then
				db_interface.commit
			end
			if reset_root_id then
				db_interface.unset_current_root_id
			end
			if reset_db then
				db_interface.unset_current_database
			end
			db_interface.operation_context_stack.remove
		ensure
			no_db_action_in_progress: not db_operation_in_progress
		end;
	
	store_shallow is
			-- Store only the attributes of this object
			-- and nothing else.
		local
			reset_root_id, reset_db : BOOLEAN
			context: DB_OPERATION_CONTEXT
		do
			!!context.make_for_store
			db_interface.operation_context_stack.put (context)
			db_interface.version_mismatch_handler.prepare
			db_interface.reset_mismatch_list
			if db_interface.current_root_id = 0 then
				reset_root_id := True
				db_interface.set_current_root_id (pobject_root_id)
			end
			if (pobject_id /= 0) and then (database /= Void) then
				db_interface.set_current_database (database)
				reset_db := True
			end
			store_shallow_obj (context)
			context.mark_objects_not_in_progress
			-- Commit to save data and release locks
			if db_interface.transaction_level = 0 then
				db_interface.commit 
			end;
			if reset_root_id then
				db_interface.unset_current_root_id
			end
			if reset_db then
				db_interface.unset_current_database
			end
			db_interface.operation_context_stack.remove
		ensure
			no_db_action_in_progress: not db_operation_in_progress		
		end; -- shallow_store
	
	
	store_difference is
			-- Store objects reachable from Current that
			-- are different from the database 
		local
			it: POBJECT;
			found_mismatch: BOOLEAN
			reset_root_id, reset_db : BOOLEAN
			context: DB_OPERATION_CONTEXT
		do
			!!context.make_for_store_difference
			db_interface.operation_context_stack.put (context)
			db_interface.version_mismatch_handler.prepare
			db_interface.reset_mismatch_list
			if db_interface.current_root_id = 0 then
				reset_root_id := True
				db_interface.set_current_root_id (pobject_root_id)
			end
			if (pobject_id /= 0) and then database /= Void then
				db_interface.set_current_database (database)
				reset_db := True
			end
			check_diff_obj (True, context)
			context.mark_objects_not_in_progress 
			-- Check the objects found different for version conflicts
			if not context.diff_stack.empty then
				from context.diff_stack.start
				until context.diff_stack.off
				loop
					it := context.diff_stack.iterated_item
					context.diff_stack.forth
					if (it.pobject_id /= 0) and then it.write_allowed then
						-- Write lock object, if we can write it
						db_interface.lock_object (it.pobject_id, db_interface.db_write_lock)
						-- Versin check must be done after locking,
						-- which refreshes the Versant cache
						if (it.pobject_version /= it.cache_version) then
							if not db_interface.version_mismatch_handler.handle (it) then
								-- Add the object to a global mismatch list
								found_mismatch := True
								db_interface.mismatch_list.extend (it)
							end
						end
					end
				end -- loop
				if found_mismatch then
					-- Mistmatches found raise and exception
					except.raise ("Version mismatch")
				end
			end -- stack not empty
			-- Now store shallow all the different objects
 			from
			until context.diff_stack.empty
			loop
				check
					is_persistent: context.diff_stack.item.pobject_id /= 0
				end
				if context.diff_stack.item.write_allowed then
					context.diff_stack.item.store_shallow_obj (context)
				else
					io.putstring ("WARNING: skiping past a read_only object. Type: ")
					io.putstring (context.diff_stack.item.generator)
					if context.diff_stack.item.pobject_id /= 0 then
						io.putstring ("  LOID=")
						io.putstring (context.diff_stack.item.external_object_id)
					end
					io.putstring (" stamp: ")
					io.putint (context.diff_stack.item.rights_stamp)
					io.new_line
				end
				context.diff_stack.remove
			end;
			context.mark_objects_not_in_progress 
			check
				stack_empty: context.objects_in_progress.empty
			end
			-- Commit to save data and release locks
			if db_interface.transaction_level = 0 then
				db_interface.commit
			end;
			if reset_root_id then
				db_interface.unset_current_root_id
			end
			if reset_db then
				db_interface.unset_current_database
			end
			db_interface.operation_context_stack.remove
		ensure
			no_db_action_in_progress: not db_operation_in_progress 
		end;
	
feature -- Retrieval

	retrieve is 
			-- Retrieve objects attributes from the database
			-- (deep retrieval)
		require
			is_persistent: pobject_id /= 0
		do
			debug ("pobject")
				io.putstring ("pobject.retrieve...%N");
			end;
			if pobject_class = Void then
				pobject_class := get_our_class;
			end;
			retrieve_obj 
		ensure
			no_db_action_in_progress: not db_operation_in_progress
		end; -- retrieve


	check_difference : LIST [POBJECT] is
			-- Compare the object structure with the
			-- contents of the database cache and return a
			-- list of objects that are different
		require
			is_persistent: pobject_id /= 0
		local
			context: DB_OPERATION_CONTEXT
		do
			!!context.make_for_store_difference
			db_interface.operation_context_stack.put (context)
			check_diff_obj (False, context);
			context.mark_objects_not_in_progress 
			check
				stack_empty: context.objects_in_progress.empty
			end
			!TWO_WAY_LIST[POBJECT]!Result.make;
 			from
			until context.diff_stack.empty
			loop
				Result.extend (context.diff_stack.item);
				context.diff_stack.remove
			end;
			db_interface.operation_context_stack.remove
		end;
	
feature -- routines that can be redefined by heirs
	
	make_transient is
			-- This routine can be redefined in descendants to init
			-- the non-persistent portions of the object
		do
		end;
	
	prepare_to_store (context: DB_OPERATION_CONTEXT) is
			-- This routine is called just before the
			-- object's attributes are scanned and stored
		do
		end

	after_store (context: DB_OPERATION_CONTEXT) is
		do
		end

feature -- copy and comparison
	
	copy, pobject_copy (other : like Current) is
			-- Copy a persistent objects
		local
			l_pobject_id : INTEGER
			l_pobject_version : INTEGER
			l_pobject_class : PCLASS
			l_pobject_root_id : INTEGER
			l_db_operation_in_progress : BOOLEAN
			l_rights_stamp : INTEGER
			l_closure_position : INTEGER
		do
			-- Save our own fields locally
			l_pobject_id := pobject_id;
			l_pobject_version := pobject_version;
			l_pobject_class := pobject_class;
			l_db_operation_in_progress := db_operation_in_progress;
			l_rights_stamp := rights_stamp;
			l_pobject_root_id := pobject_root_id
			l_closure_position := closure_position

			-- Do the copy
			identified_copy (other);

			-- Restore our fields
			pobject_id := l_pobject_id;
			pobject_version := l_pobject_version;
			pobject_class := l_pobject_class;
			db_operation_in_progress := l_db_operation_in_progress;
			rights_stamp := l_rights_stamp
			pobject_root_id := l_pobject_root_id
			closure_position := l_closure_position

		end; -- copy
	
	is_equal, pobject_is_equal (other : like Current) : BOOLEAN is
			-- Compare two POBJECTS, but ignore internal
			-- attributes (i.e. pobject_id, etc)
		local
			l_pobject_id : INTEGER
			l_pobject_version : INTEGER
			l_pobject_class : PCLASS
			l_pobject_root_id : INTEGER
			l_db_operation_in_progress : BOOLEAN
			l_rights_stamp : INTEGER
			l_closure_position : INTEGER
		do
			-- Save our own fields locally
			l_pobject_id := pobject_id;
			l_pobject_version := pobject_version;
			l_pobject_class := pobject_class;
			l_db_operation_in_progress := db_operation_in_progress;
			l_rights_stamp := rights_stamp;
			l_pobject_root_id := pobject_root_id
			l_closure_position := closure_position
			-- Next set our fields to be the same as "other"
			pobject_id := other.pobject_id;
			pobject_version := other.pobject_version;
			pobject_class := other.pobject_class;
			db_operation_in_progress := other.db_operation_in_progress;
			rights_stamp := other.rights_stamp
			pobject_root_id := other.pobject_root_id
			closure_position := other.closure_position
			-- Finally check for equallity
			Result := identified_is_equal (other);
			-- Restore our fields
			pobject_id := l_pobject_id;
			pobject_version := l_pobject_version;
			pobject_class := l_pobject_class;
			db_operation_in_progress := l_db_operation_in_progress;
			rights_stamp := l_rights_stamp
			pobject_root_id := l_pobject_root_id
			closure_position := l_closure_position
		end;
	

feature -- refreshing Eiffel objects from db

	refresh is
		require
			is_persistent: pobject_id /= 0
		local
			context: DB_OPERATION_CONTEXT
		do
			!!context.make_for_retrieve
			db_interface.operation_context_stack.put (context) 
			if pobject_class = Void then
				pobject_class := get_our_class
			end
			refresh_obj (context);
			context.mark_objects_not_in_progress 
			check
				stack_empty: context.objects_in_progress.empty
			end
			db_interface.operation_context_stack.remove
		ensure
			op_done: not db_operation_in_progress
		end;
	
	refresh_shallow, pobject_refresh_shallow is
		require
			is_persistent: pobject_id /= 0
		local
			attr: SPECIAL [PATTRIBUTE]
			i, total: INTEGER
			obj_ptr: POINTER
			changed: BOOLEAN
			eif_id, err: INTEGER
		do
			if pobject_class = Void then
				pobject_class := get_our_class
			end

			-- Save the eiffel_id from the object
			obj_ptr := db_interface.c_ptrfromcod (pobject_id)
			-- eif_id := db_interface.get_db_int_o_ptr (obj_ptr, 8)
			eif_id := db_interface.c_get_peif_id (obj_ptr)

			-- Refresh the contents from database
			db_interface.o_refreshobj (pobject_id, 0, $changed)

			-- put the eiffel_id back in the object
			-- and clear the "was_modified" flag
			db_interface.c_set_peif_id_and_clear_wm (obj_ptr, eif_id)

			if db_interface.nbpins (pobject_id) > 1 then
				-- Undo the pin done by refresh
				-- Only called when needed.
				err  := db_interface.o_unpinobj (pobject_id, 0)
			end

			attr := pobject_class.attributes_array.area

			from
				i := 0 
				total := attr.count - 1
			until
				i > total
			loop
				attr.item (i).refresh_attr (Current, False, obj_ptr)
				i := i + 1
			end
			publish (Void)
		ensure
			op_done: not db_operation_in_progress
		end

	

feature {DB_INTERNAL, POBJECT, PERSISTENT_ROOTS, POBJECT_SCAN, DATABASE}
	
	make_persistent is
		require
			not_persistent: pobject_id = 0;
		local
			class_id: INTEGER
			ptr: POINTER
		do
			pobject_class := get_our_class;
			if pobject_root_id /= 0 then
				db_interface.verify_root_id_and_database (Current)
			end
			-- Set access stamp. We have all the rights to
			-- this object as we just created it
			rights_stamp := db_interface.read_write_allowed
			-- Crash if we are not allowed to store this
			-- object. This could happen because the type
			-- maybe under restrictive management
			if not allowed_to_store then
				except.raise ("Cannot store this object.")
			end
			pobject_id := db_interface.o_makeobj (pobject_class.pobject_id, 
							      default_pointer, True)
			check_error
			-- Now add this object to the object_table
			db_interface.object_table.put (Current, pobject_id);
			debug ("pobject")
				io.putstring ("POBJECT.make_persistent: class=")
				io.putstring (generator);
				io.putstring (" Root_id=");
				io.putint (pobject_root_id);
				io.new_line
			end
			-- Add new object to Rollback log
			db_interface.rollback_log.put (Current)
		ensure
			is_persistent: pobject_id /= 0;
		end; -- make_persistent
	
feature {DB_INTERNAL, DB_INTERFACE_INFO, DB_OPERATION_CONTEXT, POBJECT}

	mark_not_in_progress is
		do
			db_operation_in_progress := False;
		end;
	
	mark_in_progress (context: DB_OPERATION_CONTEXT) is
		do
			db_operation_in_progress := True;
			context.objects_in_progress.put (Current);
		end;

	db_operation_in_progress : BOOLEAN;
			-- true if already stored


feature {DB_INTERNAL, PERSISTENCY_ROOT}
	
	
	change_root (new_root_id : INTEGER) is
			-- Mark all the objects that belong to the
			-- same root as Current as belonging to a new
			-- root, with id "new_root_id"
		local
			context: DB_OPERATION_CONTEXT
		do
			!!context.make_for_store
			db_interface.operation_context_stack.put (context) 
			change_root_obj (new_root_id, pobject_root_id, context)
			context.mark_objects_not_in_progress 
			db_interface.operation_context_stack.remove
		ensure
			no_db_action_in_progress: not db_operation_in_progress
		end

feature {DB_INTERNAL, PERSISTENCY_ROOT, POBJECT, PATTRIBUTE}

	
	check_diff_obj, pobject_check_diff_obj (make_new_persistent: BOOLEAN; context: DB_OPERATION_CONTEXT) is
		local
			unset, is_different: BOOLEAN
			i: INTEGER
			attr: SPECIAL [PATTRIBUTE]
			obj_attr: SPECIAL [OBJECT_PATTRIBUTE]
			obj: POBJECT
			obj_ptr: POINTER
		do
			if not db_operation_in_progress then
				if pobject_class = Void then
					pobject_class := get_our_class
				end;
				-- make the object persistent, if the caller wants\
				if pobject_id = 0 then
					if make_new_persistent then
						make_persistent
					end
					-- New or non persistemt objects are automatically different
					is_different := True
				end
				-- Next take care of the root_id
				if (pobject_root_id /= 0) then 
					-- Set current root_id for the traversal
					if (pobject_root_id /= db_interface.current_root_id) and 
						(pobject_id /= 0) 
					 then
						set_root_id_and_database
						unset := True
					end
				else
					-- Set this object's root_id to the current root_id
					set_root_id (db_interface.current_root_id)
				end
				mark_in_progress (context);
				--
				-- Traverse attributes and check for diffs
				--
				if not is_different then
					attr := pobject_class.attributes_array.area
					from
						i := 0 
						obj_ptr := db_interface.c_ptrfromcod (pobject_id)
					until
						is_different or (i > attr.count - 1)
					loop
						is_different := attr.item (i).is_different (Current, obj_ptr)
						i := i + 1
					end
				end
				-- Now follow the closure and check other objects
				if  pobject_class.reference_attributes /= Void then
					obj_attr := pobject_class.reference_attributes.area
					from i := 0
					until i > obj_attr.count - 1
					loop
						obj := obj_attr.item (i).value (Current)
						if obj /= Void then
							obj.check_diff_obj (make_new_persistent, 
									    context)
						end
						i := i + 1
					end
				end
				-- If there were differences, place Current on the stack
				if is_different then
					context.diff_stack.put (Current)
				end
				-- Reset current db if needed
				if unset then
					unset_root_id_and_database
				end
			end;
		ensure
			op_in_progress: db_operation_in_progress 
		rescue
			if unset then
				unset_root_id_and_database
			end
		end;
	
feature {DB_INTERNAL, PATTRIBUTE, POBJECT}
	
	
	reset_stamp_obj, pobject_reset_stamp_obj (context: DB_OPERATION_CONTEXT) is
		local
			attr: SPECIAL [OBJECT_PATTRIBUTE]
			i: INTEGER
			obj: POBJECT
		do
			if not db_operation_in_progress then
				mark_in_progress (context)
				if pobject_class = Void then
					pobject_class := get_our_class
				end
				if pobject_id /= 0 then
					rights_stamp := pobject_class.db.rights_stamp_by_id (pobject_root_id)
				end
				-- Then do the rest of the closure
				if  pobject_class.reference_attributes /= Void then
					attr := pobject_class.reference_attributes.area
					from i := 0
					until i > attr.count - 1
					loop
						obj := attr.item (i).value (Current)
						if obj /= Void then
							obj.reset_stamp_obj (context)
						end
						i := i + 1
					end
				end
			end
		end
	
feature {DB_INTERNAL, POBJECT_REF_SCAN, POBJECT}	
	
	change_root_obj, pobject_change_root_obj (new_root_id, old_root_id : INTEGER; context: DB_OPERATION_CONTEXT) is
		local
			i: INTEGER
			attr: SPECIAL [OBJECT_PATTRIBUTE]
			obj: POBJECT
		do
			if not db_operation_in_progress then
				mark_in_progress (context)
				-- Change the root_id if the same as
				-- the old ID 
				if pobject_root_id = old_root_id then
					set_root_id (new_root_id);
				end
				-- make sure we have retrieved our PCLASS
				if pobject_class = Void then
					pobject_class := get_our_class
				end
				-- Then do the rest of the closure
				if pobject_class.reference_attributes /= Void then
					attr := pobject_class.reference_attributes.area
					from i := 0
					until i > attr.count - 1
					loop
						-- Get the object this attribute references
						obj := attr.item (i).value (Current)
						if obj /= Void then
							obj.change_root_obj (new_root_id, 
									     old_root_id,
									     context)
						end
						i := i + 1
					end
				end
			end
		end

feature {DB_INTERNAL, POBJECT, POBJECT_REFRESHER, PERSISTENCY_ROOT, PATTRIBUTE}

	refresh_obj, pobject_refresh_obj (context: DB_OPERATION_CONTEXT) is
			-- Refresh object from the database
		local
			attr: SPECIAL [PATTRIBUTE]
			i, total: INTEGER
			obj_ptr: POINTER
			changed: BOOLEAN
			eif_id, err: INTEGER
		do
			if not db_operation_in_progress then
				mark_in_progress (context)

				-- Save the eiffel_id from the object
				obj_ptr := db_interface.c_ptrfromcod (pobject_id)
--				eif_id := db_interface.get_db_int_o_ptr (obj_ptr, 8)
				eif_id := db_interface.c_get_peif_id (obj_ptr)

				-- Refresh the contents from database
				db_interface.o_refreshobj (pobject_id, 0, $changed)

				-- put the eiffel_id back in the object
				-- and clear the "was_modified" flag
				db_interface.c_set_peif_id_and_clear_wm (obj_ptr, eif_id)

				if db_interface.nbpins (pobject_id) > 1 then
					-- Undo the pin done by refresh
					-- Only called when needed.
					err  := db_interface.o_unpinobj (pobject_id, 0)
				end

				attr := pobject_class.attributes_array.area

				from
					i := 0 
					total := attr.count - 1
				until
					i > total
				loop
					attr.item (i).refresh_attr (Current, True, obj_ptr)
					i := i + 1
				end
				publish (Void)
			end
		ensure
			op_in_progress: db_operation_in_progress
		end

feature {DB_INTERNAL, POBJECT_READER, DB_INTERFACE_INFO, PATTRIBUTE}

	retrieve_obj, pobject_retrieve_obj is
			-- Retrieve object
		local
			attr: SPECIAL [PATTRIBUTE]
			i: INTEGER
			obj_ptr: POINTER
		do
			attr := pobject_class.attributes_array.area
			from
				i := 0 
				obj_ptr := db_interface.c_ptrfromcod (pobject_id)
			until
				i > attr.count - 1
			loop
				attr.item (i).retrieve_attr (Current, obj_ptr)
				i := i + 1
			end
		end; -- retrieve_object

feature {DB_INTERNAL, POBJECT, PERSISTENCY_ROOT, DATABASE, PERSISTENT_ROOTS, PATTRIBUTE}
	

	store_obj, pobject_store_obj (context: DB_OPERATION_CONTEXT) is
			-- Store object's attributes
		local
			unset: BOOLEAN
			attr: SPECIAL [PATTRIBUTE]
			i: INTEGER
			obj_ptr: POINTER
		do
			if allowed_to_store then
				-- We will only attempt a store if
				-- it's called from the appropriate
				-- maneger, if one is present
				if not db_operation_in_progress then
					debug ("pobject")
						io.putstring ("pobject.store_obj -  no operation in progress%N");
					end;
					if (pobject_id /= 0) and then 
						(pobject_root_id /= db_interface.current_root_id)
					 then
						set_root_id_and_database
						unset := True
					end
					if pobject_id = 0 then
						-- must make a new object in the database
						make_persistent
					else
						-- Write lock this object
						db_interface.lock_object (pobject_id, 
									  db_interface.db_write_lock)
					end
					-- Check object version
					if cache_version /= pobject_version then
						if db_interface.version_mismatch_handler.handle (Current) then
							-- If get here, force the version number to be correnct
							pobject_version := cache_version
						else
							db_interface.mismatch_list.extend (Current)
							except.raise ("Version mismatch")
						end
					end
					-- Add to rollback_log if not a brand a new object
					if pobject_version /= 0 then
						db_interface.rollback_log.put (Current)
					end
					-- Increment the version that will go into the database.
					-- The increment is done MOD 90000000 to prevent overflow.
					-- That's how many write can occur by others to this
					-- object while we're holding it.
					pobject_version := (pobject_version + 1) \\ 90000000;
					
					-- Custom preparation for storing
					prepare_to_store (context)
					-- Now update the database attributes
					mark_in_progress (context);
					--OLD CODE  writer.traverse (Current);
					-- Set the root ID, if not yet set
					if pobject_root_id = 0 then
						set_root_id (db_interface.current_root_id)
					end
					--- store the attributes
					attr := pobject_class.attributes_array.area
					from
						i := 0 
						obj_ptr := db_interface.c_ptrfromcod (pobject_id)
					until
						i > attr.count - 1
					loop
						attr.item (i).store_attr (Current, obj_ptr)
						i := i + 1
					end
					db_interface.o_setdirty (pobject_id)
					after_store (context)
					if unset then
						unset_root_id_and_database
					end
				end
			end
		ensure
			is_persistent: pobject_id /= 0;
			op_in_progress: allowed_to_store implies db_operation_in_progress
		rescue
			if unset then
				unset_root_id_and_database
			end			
		end; -- store
	
	
	store_shallow_obj, pobject_store_shallow_obj (context: DB_OPERATION_CONTEXT) is
		local
			attr: SPECIAL [PATTRIBUTE]
			i: INTEGER
			obj_ptr: POINTER
		do
			if allowed_to_store and not db_operation_in_progress
			 then
				if pobject_id = 0 then
					-- must make a new object in the database
					make_persistent
				else
					db_interface.lock_object (pobject_id, 
						db_interface.db_write_lock);
				end
				-- Check object version
				if cache_version /= pobject_version then
					if db_interface.version_mismatch_handler.handle (Current) then
						-- If get here, force the version number to be correnct
						pobject_version := cache_version
					else
						db_interface.mismatch_list.extend (Current)
						except.raise ("Version mismatch")
					end
				end
				-- Add to rollback_log if not a brand a new object
				if pobject_version /= 0 then
					db_interface.rollback_log.put (Current)
				end
				-- Increment the version that will go into the database.
				-- The increment is done MOD 90000000 to prevent overflow.
				-- That's how many write can occur by others to this
				-- object while we're holding it.
				pobject_version := (pobject_version + 1) \\ 90000000;
				
				-- Custom preparation for storing
				prepare_to_store (context)				
				-- Now update the database attributes
				mark_in_progress (context);
				-- shallow_writer.traverse (Current);
				attr := pobject_class.attributes_array.area
				from
					i := 0 
					obj_ptr := db_interface.c_ptrfromcod (pobject_id)
				until
					i > attr.count - 1
				loop
					attr.item (i).store_shallow_attr (Current, obj_ptr)
					i := i + 1
				end
				db_interface.o_setdirty (pobject_id)
				after_store (context)
			else
				debug ("pobject")
					io.putstring ("pobject: skipping shallow_store%N"); 
				end
			end;
		ensure
			op_in_progress: allowed_to_store implies db_operation_in_progress
		end; -- store_shallow_obj	

feature {DB_INTERNAL, POBJECT_SCAN, POBJECT_REF_SCAN, DATABASE}
	
	set_root_id (new_id : INTEGER) is
		local
			obj_ptr: POINTER
		do
			-- Set the value in the Eiffel object
			pobject_root_id := new_id
			if pobject_id /= 0 then
				db_interface.verify_root_id_and_database (Current)
				-- Set the value in the database object
				obj_ptr := db_interface.c_ptrfromcod (pobject_id)
				db_interface.set_db_int_o_ptr (obj_ptr, 4, pobject_root_id)
				db_interface.o_setdirty (pobject_id)
				check_error
			end
		end
	
	reset_pobject_class is
			-- reset object pclass
		do
			pobject_class := Void 
			pobject_class := get_our_class
		end

feature {DB_INTERNAL, DB_INTERFACE_INFO}
	
	
	set_pobject_class (new_class : PCLASS) is
		require
			class_ok: new_class /= Void
		do
			-- Should check here that the types match
			-- excatly, otherwise we'll have trouble
			-- *****pontential bugs *****
			pobject_class := new_class
			if not pobject_class.initialized then
				pobject_class.init_offsets (Current)
			end
		end

	set_pobject_id (new_id : INTEGER) is
			--  Set pobject_id
		require
			new_id /= 0
		do
			pobject_id := new_id;
		end; -- set_pobject_id
	
	recover_after_abort, pobject_recover_after_abort is
			-- Called after aborted store operation to
			-- undo changes in the Eiffel object
		do
			-- Decrement the version number, if it's not already zero
			if pobject_version > 0 then
				pobject_version := pobject_version - 1
			end
			-- If version number is 0, the wipe_out
			-- pobject_id, as the store never happened
			if pobject_version = 0 then
				pobject_id := 0
			end
		end


feature {DB_INTERNAL, DB_GLOBAL_INFO}
	

	get_our_class : PCLASS is
		local
			class_id : INTEGER
		do
			if pobject_class = Void then
				if db_interface.view_table.is_db_creatable (generator) then
					if pobject_id = 0 then
						-- Find class for new object in the
						-- current database
						class_id := db_interface.current_database.find_class_id (
							db_interface.view_table.versant_class (generator));
					else
						-- Find class for an existing object
						class_id := db_interface.o_classobjof (pobject_id);
					end
					if class_id = 0 then
						check_error
					end
					Result := db_interface.find_class_by_class_id (class_id);
					if Result = Void then
						io.putstring ("***ERROR: class ");
						io.putstring (generator);
						io.putstring (" not in schema. %N")
						except.raise ("schema error");
					end;
					if not Result.initialized then
						Result.init_offsets (Current)
					end
				else
					io.putstring ("***ERROR: VIEW ");
					io.putstring (generator);
					io.putstring (" cannot be created in the DB. %N")
					except.raise ("view error");
				end
			else
				Result := pobject_class
			end
		ensure
			schema_ok: (Result /= Void) and (Result.initialized)
		end
	
	
feature {DB_INTERNAL, VERSION_MISMATCH_HANDLER, PERSISTENT_ROOTS, POBJECT}

	cache_version : INTEGER is
		local
			obj_ptr: POINTER
		do
			obj_ptr := db_interface.c_ptrfromcod (pobject_id)
			Result := db_interface.get_db_int_o_ptr (obj_ptr, 0)
		end
	
feature {DB_INTERNAL}
	

	allowed_to_store : BOOLEAN is
		do
			-- If we don't have privs to store, raise an exception
			if pobject_class = Void then
				pobject_class := get_our_class;
			end;
			if (pobject_id /= 0) and not write_allowed then
				except.raise ("Attempt to write read-only object")
			else
				Result := (pobject_class.my_manager = Void) or else
				          (db_interface.current_manager = pobject_class.my_manager) 
			end
		end;


	set_root_id_and_database is
		do
			db_interface.set_current_root_id (pobject_root_id)
			db_interface.set_current_database (database)
		end
	
	unset_root_id_and_database is
		do
			db_interface.unset_current_root_id 
			db_interface.unset_current_database
		end
		
feature {DB_INTERNAL, DATABASE, POBJECT, POBJECT_CLOSURE_SCANNER, POBJECT_ACTION_COMMAND} -- computation of closures	
	
	closure_position : INTEGER
			-- positon in the closure list, while closure
			-- is being computed
	
	set_closure_position (new_pos : INTEGER) is
		do
			closure_position := new_pos
		end

	ith_ref, ith_mem_ref, pobject_ith_ref, pobject_ith_mem_ref (i : INTEGER) : POBJECT is
			-- i-th reference attribute (no error checking this code has to be fast)
			-- "ith_ref" and "ith_mem_ref" can be different for PLISTs
		local
			pattr : PATTRIBUTE
		do
			pattr := pobject_class.reference_attributes.area.item (i - 1)
			Result := db_interface.extract_reference (pattr.eiffel_offset, $Current)
		end
	
	set_ith_ref, pobject_set_ith_ref (i : INTEGER; object : POBJECT) is
			-- Set the ith reference
		local
			pattr : PATTRIBUTE
		do
			pattr  := pobject_class.reference_attributes.area.item (i - 1)
			db_interface.set_nth (pattr.eiffel_offset, $Current, $object)
		end
	
	ref_count, pobject_ref_count : INTEGER is
			-- number of reference attributes
		do
			if pobject_class = Void then
				pobject_class := get_our_class
			end
			if pobject_class.reference_attributes /= Void then
				Result := pobject_class.reference_attributes.count
			end
		end

feature {NONE}
 
	dispose, pobject_dispose is
		do
			free_id
			if pobject_id /= 0  and then c_is_session_active then
				db_interface.object_table.dispose_object (pobject_id)
			end
		end

	c_is_session_active: BOOLEAN is
		external "C"
		end

end -- POBJECT

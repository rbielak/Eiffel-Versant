-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Various tables and routines required for the Database interface
--

class DB_INTERFACE_INFO
	
inherit

	VERSANT_EXTERNALS
	VERSANT_POINTER_EXTERNALS
	EIF_VERS_EXTERNALS
	EXCEPTIONS
	DB_CONSTANTS
	EIFFEL_EXTERNALS
	MEMORY

creation

	make
	
	
feature {DB_GLOBAL_INFO, ROOT_SERVER}

	current_manager : MAN_SPEC [MANAGEABLE] is
			-- Current manager, if any
		do
			if not man_stack.empty then
				Result := man_stack.item
			end
		end

	man_stack : SE_STACK [MAN_SPEC [MANAGEABLE]];

	set_current_manager (new_man : MAN_SPEC [MANAGEABLE]) is
		require
			new_man /= Void 
		do
			man_stack.put (new_man);
			set_current_database (new_man.root_database)
			set_current_root_id (new_man.root_id);
		end;
	
	unset_current_manager is
		require
			current_manager /= Void
		do
			man_stack.remove
			unset_current_database
			unset_current_root_id
		end

	session_database: DATABASE
			-- database to which we connected first

	set_session_database (db: DATABASE) is
		require
			db_ok: (db /= Void) and then db.is_connected
		do
			session_database := db
		ensure
			session_database = db
		end

	current_database : DATABASE is
			-- The current database (if Void, then it's
			-- the default session db)
		do
			Result := db_stack.item;
		ensure
			Result /= Void
		end
	
	verify_root_id_and_database (object : POBJECT) is
			-- Check that the root_id in the object is
			-- consistent with it's database
		require
			has_pclass: object.pobject_class /= Void
		local
			root_db_id, db_id: INTEGER
		do
			root_db_id := object.pobject_root_id // max_roots_per_db
			if root_db_id /= 0 then
				db_id := object.pobject_class.db.database_id
				if root_db_id /= db_id then
					io.putstring ("ERROR: Trying to store in wrong database.%N")
					io.putstring ("  object db_id: ")
					io.putint (root_db_id)
					io.putstring (" database id=");
					io.putint (db_id)
					io.new_line;
					io.putstring (object.tagged_out)
					raise ("storing in wrong database")
				end
			end
		end

feature {DB_GLOBAL_INFO, ROOT_SERVER}

	set_current_database (db : DATABASE) is
			-- Set the current database
		require
			db_connected: (db /= Void) implies (db.is_connected)
		do
			db_stack.put (db)
		end
	
	unset_current_database is
			-- Go back to previous database
		do
			db_stack.remove
		ensure
			not db_stack.empty
		end
	
	db_stack : SE_STACK [DATABASE]
			-- Top database is the current database
	
	active_databases : ACTIVE_DB_TABLE;
			-- databases we are connected to
	
	defined_databases: HASH_TABLE [DATABASE, STRING]
			-- databases that we were connected to at one
			-- time or another

feature {DB_GLOBAL_INFO, ROOT_SERVER} -- Stamping
	
	
	root_id_stack : SE_STACK [INTEGER]
	
	current_root_id : INTEGER is
		do
			Result := root_id_stack.item
		end
	
	set_current_root_id (new_id : INTEGER) is
		require
			id_valid: new_id >= 0
		do
			root_id_stack.put (new_id)
		end
	
	unset_current_root_id is
		require
			stack_valid: root_id_stack.count > 1
		do
			root_id_stack.remove
		end

feature {DB_GLOBAL_INFO}
	
	
	version_mismatch_handler : VERSION_MISMATCH_HANDLER
			-- object to deal with version mismatch errors
	
	set_version_mismatch_handler (new_handler : VERSION_MISMATCH_HANDLER) is
		require
			handler_ok: new_handler /= Void
		do
			version_mismatch_handler := new_handler
		end
	
	
	mismatch_list : FAST_LIST [POBJECT]
			-- list of objects that had mismatched version
			-- found during the last "store_difference" operation
	
	reset_mismatch_list is
			-- Reset the mismatch list
		do
			!!mismatch_list.make
		end
	
	session_is_active : BOOLEAN;
	
	set_session_is_active (value : BOOLEAN) is
		do
			session_is_active := value;
			c_set_session_active (value);
		end;
	
	restricted_managers : HASH_TABLE [MAN [MANAGEABLE], STRING];
			-- Managers for specific classes

	object_table : POBJECT_TABLE;
			-- Table of objects we read from the database
	
	rollback_log: SE_STACK [POBJECT] 
			-- stack of objects that were stored during
			-- the current transaction. The abort routine
			-- uses this log to undo change made by
			-- "store" routines
	
	diff_stack: SE_STACK [POBJECT]
			-- stack of objects that were found different
			-- during "check_difference" or "store_difference"
	
	operation_context_stack: SE_STACK [DB_OPERATION_CONTEXT]
			-- used for nested db operations
	
	clean_up_in_progress_stack_on_abort is
		local
			object: POBJECT
		do
			from 
			until 
				operation_context_stack.empty
			loop
				operation_context_stack.item.clean_up_on_abort
				operation_context_stack.remove
			end
		end
	
	
	find_class_for_object (pobject_id: INTEGER) : PCLASS is
		require
			pobject_id_valid: pobject_id /= 0
		local
			class_id: INTEGER
		do
			class_id := o_classobjof (pobject_id);
			if last_error /= 0 then
				io.putstring ("Died getting class id for objectID=")
				io.putstring (c_get_loid (pobject_id)); io.new_line;
				io.putstring (" Error="); io.putint (last_error);
				io.new_line;
				raise ("Can't get class");
			end;
			-- Get the schema class object too
			Result := find_class_by_class_id (class_id);
			if Result = Void then
				io.putstring ("****ERROR: can't find schema for class id:");
				io.putint (class_id); io.new_line;
				raise ("schema error");
			end;
		end

	retrieved_stack : SE_STACK [POBJECT] -- ARRAYED_QUEUE [POBJECT]
			-- for keeping track of objects during retrieval (stack maybe?)

	upgrade_mode: BOOLEAN
			-- true if doing special processing in upgrade mode
	
	unwanted_make_transient: HASH_TABLE [STRING, STRING] is
			-- Classes on which "make_transient" should not be called
			-- (only used in upgrade mode)
		once
			!!result.make (10)
		end
	
	add_unwanted_make_transient (lclass_name: STRING) is
		do
			upgrade_mode := True
			unwanted_make_transient.put (lclass_name, lclass_name)
		end

	rebuild_eiffel_object (pobject_id : INTEGER) : POBJECT is
		require
			valid_oid: pobject_id /= 0
		local
			gc_was_on, first_entry: BOOLEAN
			crashed: BOOLEAN
			pins: INTEGER
		do
			if not crashed then
				first_entry := retrieved_stack.empty
				gc_was_on := collecting
				if gc_was_on then
					collection_off
				end
				Result := create_eiffel_object (pobject_id)
				if gc_was_on then
					collection_on
				end
			end
			-- Retrieval done, call 'make_transient' on retrieved objects
			-- this code will be run even after an exception occurs in retrieve
			if first_entry then
				clean_retrieved_stack
			end
			-- If there was an exception, then propagate it to the caller
			if crashed then
				raise ("incomplete retrieval exception")
			end
		rescue
			-- Only retry the exception if this is the top level call
			if not crashed and first_entry then
				crashed := True
				retry
			end
		end

	clean_retrieved_stack is
		local
			temp: BOOLEAN
		do
			-- turn assertions off for calling make_transients
			-- invariants may not be valid on objects created by the 
			-- retrieval code
			temp := c_check_assert (FALSE);
			if upgrade_mode then
				from
				until
					retrieved_stack.empty
				loop
					if not unwanted_make_transient.has (retrieved_stack.item.pobject_class.eiffel_name) then
						retrieved_stack.item.make_transient
					end
					retrieved_stack.remove
				end
			else
				from
				until
					retrieved_stack.empty
				loop
					retrieved_stack.item.make_transient
					retrieved_stack.remove
				end
			end
			-- done turn assertion checking back
			temp := c_check_assert (temp);
		end

	create_eiffel_object (pobject_id : INTEGER) : POBJECT is
			-- Create an Eiffel object given the database
			-- object ID (we may only look it up)
		require
			valid_oid: pobject_id /= 0
		local
			class_id : INTEGER;
			l_stamp : INTEGER
			temp : BOOLEAN;
			pclass : PCLASS;
			plist : PLIST[POBJECT];
			ptr: POINTER
		do
			-- See if we already have this object
			Result := object_table.item (pobject_id);
			if Result = Void then
				ptr := o_locateobj (pobject_id, 0)
				pclass := find_class_for_object (pobject_id)
				-- Then create the object
				ei_class.make_from_name (pclass.eiffel_name);
				if ei_class.class_id = -1 then
					io.putstring ("ERROR: Class not defined in your Eiffel system%N")
					io.putstring ("Please recompile after inserting the right FEEDER%N")
					io.putstring ("for class: ")
					io.putstring (pclass.eiffel_name)
					io.new_line;
					raise ("Class not in system")
				end
				-- Turn assertions checking off, while we
				-- creating the new object
				temp := c_check_assert (FALSE);
				Result ?= ei_class.allocate_object;
				if Result /= Void then
					object_table.put (Result, pobject_id);
					Result.set_pobject_id (pobject_id);
					Result.set_pobject_class (pclass);
					retrieved_stack.put (Result)
					Result.retrieve_obj
				end
				-- Set the rights stamp for newly retrieved objects
				if Result /= Void then
					-- Result.set_rights_stamp (current_rights_stamp);
					l_stamp := pclass.db.rights_stamp_by_id (Result.pobject_root_id)
					Result.set_rights_stamp (l_stamp);
				end
				temp := c_check_assert (temp); 
			end; -- if Result = Void
		end; -- create_eiffel_object
	
	pclass_table : INTEGER_KEYED_HASH_TABLE [PCLASS];
			-- Table of classes we needed so far, indexed
			-- by the class's persistent object ID
	
	
	force_class_on_new_object (object : POBJECT; db : DATABASE) is
			-- Force a class definition on a new object.
			-- By retrieving the class from the specified
			-- db, we force the object to be stored in
			-- that db.
		require
			object_ok: (object /= Void) and then (object.pobject_id = 0)
			db_ok: (db /= Void) and then (db.is_connected)
		local
			class_id : INTEGER
			my_class : PCLASS
		do
			class_id := db.find_class_id (object.generator);
			if class_id = 0 then
				print ("***ERROR: class missing from schema: ")
				print (object.generator)
				print ("%N")
				raise ("Class missing from schema")
			end
			my_class := find_class_by_class_id (class_id);
			-- Make sure the class is ready for store operations
			if not my_class.initialized then
				my_class.init_offsets (object)
			end
			object.set_pobject_class (my_class)
			verify_root_id_and_database (object)
		ensure
			object.pobject_class /= Void
		end
	
	find_class_by_class_id (pobject_id : INTEGER) : PCLASS is
		require
			class_id_ok: pobject_id /= 0
		local
			the_class : PCLASS
			eif_class_name : STRING;
		do
			-- Check global hash table to see if we have this class already
			Result := pclass_table.item (pobject_id);
			if Result = Void then
				-- I guess not, so get it from database
				!!the_class.make_by_id (pobject_id);
				the_class.retrieve_class;
				pclass_table.put (the_class, pobject_id);
				Result := the_class
			end
		ensure
			Result /= Void
		end

	find_class (eif_class_name : STRING) : PCLASS is
			-- Return a description of the schema class
		require
			class_name_ok : eif_class_name /= Void;
		local
			my_class : PCLASS;
			my_class_id : INTEGER;
		do
			debug
				io.putstring ("find_class: ");
				io.putstring (eif_class_name);
				io.putstring (" in database <");
				io.putstring (current_database.name);
				io.putstring ("> %N");
			end;
			my_class_id := current_database.find_class_id (eif_class_name);
			if my_class_id /= 0 then
				Result := find_class_by_class_id (my_class_id);
			end
		end; -- find_class
	
	make is
		do
			!!pclass_table.make (301)
			!!object_table
			!!restricted_managers.make (51)
			!!rollback_log.make (500)
			!!locks.make (200)
			!!active_databases.make
			!!db_stack.make (50)
			!!man_stack.make (20)
			!!root_id_stack.make (50)
			!!operation_context_stack.make (20)
			!!retrieved_stack.make (500)
			!!before_commit_actions.make (40)
			-- ID for no-man is at the bottom of the stack
			root_id_stack.put (0)
			!!defined_databases.make (10)
			-- Assume event notification is on
			events_active := True
			!!event_stack.make (50)
		end;

	
	locks : SE_STACK [DB_LOCK [POBJECT]];
			-- locks taken out during a transaction

	lock_object (oid : INTEGER; lock_code : INTEGER) is
			-- Lock an object
		require
			object_id_ok: oid /= 0
		local
			changed: BOOLEAN
			obj_ptr: POINTER
			eif_id, err: INTEGER
		do
			obj_ptr := c_ptrfromcod (oid)
			-- eif_id := get_db_int_o_ptr (obj_ptr, 8)
			eif_id := c_get_peif_id (obj_ptr)

			if not is_dirty (oid) then
				-- Only refresh the object if it's not dirty
				o_refreshobj (oid, lock_code, $changed)
				if nbpins (oid) > 1 then
					err := o_unpinobj (oid, 0)
				end
			else
				err := o_acquireslock (oid, lock_code)
				if nbpins (oid) > 1 then
					err := o_unpinobj (oid, 1)
				end
			end

			if last_error /= 0 then
				io.putstring ("*** Error locking object=");
				io.putint (last_error);
				io.putstring ("  LOID=")
				io.putstring (c_get_loid (oid))
				io.new_line;
				raise ("cannot lock object");
			end

			-- set_db_int_o_ptr (obj_ptr, 8, eif_id)
			c_set_peif_id_and_clear_wm (obj_ptr, eif_id)
		end
	
	unlock_object (oid : INTEGER) is
			-- Release any locks held on an object
		require
			object_id_ok: oid /= 0;		
		local
			error : INTEGER;
		do
			error := o_downgradelock (oid, db_no_lock);
			if error /= 0 then
				io.putstring ("*** Error unlocking object=");
				io.putint (error);
				io.new_line;
				raise ("cannot unlock object");
			end
		end;

	before_commit_actions: SE_STACK [DEFERRED_DB_ACTION]
			-- things that were deferred until commit

	commit is
			-- Commit current transaction
		require
			correct_tran_level: transaction_level = 0
		local
			last_event: DB_EVENT
		do
			debug ("transaction")
				io.putstring ("DB_INTERFACE.commit called%N")
			end
			-- perform any deferred actions
			-- bump the transaction level to avoid infinite recursion
			transaction_level := 1
			from 
			until before_commit_actions.empty
			loop
				before_commit_actions.item.action_on_commit
				before_commit_actions.remove
			end
			-- reset back to 0, since we are committing
			transaction_level := 0

			if c_commit /= 0 then
				io.putstring ("*****VERSANT ERROR: ");
				io.putint (last_error);
				io.new_line;
				raise ("db_interface.commit failed");
			end
			-- Reset all locks
			from 
			until locks.empty
			loop
				locks.item.reset_lock_flags
				locks.remove
			end
			locks.wipe_out
			-- Clear "write_log"
			rollback_log.wipe_out
			-- Send all pending events, if event publisher is active
			if db_event_publisher /= Void and then
				db_event_publisher.is_enabled then
				from
				until event_stack.empty
				loop
					if last_event = Void then
						db_event_publisher.publish_event (event_stack.item)
					elseif  not last_event.same_as (event_stack.item) then
						db_event_publisher.publish_event (event_stack.item)
					end
					last_event := event_stack.item
					event_stack.remove
				end -- loop
			else
				event_stack.wipe_out
			end
		ensure
			tran_level_consistent: transaction_level = 0
			unlocked: locks.empty
			events_reported: event_stack.empty
			actions_done: before_commit_actions.empty
			log_reset: rollback_log.empty
		end;
	
feature {DB_SESSION, POBJECT, DB_INTERNAL}

	abort is 
		local
			gc_was_on: BOOLEAN
			timer: SIMPLE_TIMER
			obj_ptr: POINTER
			obj: POBJECT
		do
			debug ("transaction")
				io.putstring ("DB_INTERFACE.abort called%N")
				!!timer
				timer.start
			end
			gc_was_on := collecting
			if gc_was_on then
				collection_off
			end
			-- handle deferred updaters
			from 
			until before_commit_actions.empty
			loop
				before_commit_actions.item.action_on_abort
				before_commit_actions.remove
			end
			-- Actually abort the transaction
			if c_abort /= 0 then
				io.putstring ("*****VERSANT ERROR: ");
				io.putint (last_error);
				io.new_line;
				raise ("db_interface.abort failed");
			end
			-- Repin all objects in Versant cache
-- NOT NEEDED in Versant 5.0.7 and later
--			if c_repin_all_objects /= 0 then
--				io.putstring ("*****VERSANT ERROR: ");
--				io.putint (last_error);
--				io.new_line;
--				raise ("db_interface.abort (reset all pins) failed");
--			end
			-- Reset all locks
			from 
			until locks.empty
			loop
				locks.item.reset_lock_flags
				locks.remove
			end
			-- clean up any objects still marked in progress
			clean_up_in_progress_stack_on_abort
			-- Clean up current managers
			from
			until man_stack.empty
			loop
				unset_current_manager
			end
			-- Clean up and repin any objects that were in write_log
			from
			until rollback_log.empty
			loop
				-- repin object after abort
				obj := rollback_log.item
				if not is_pinned (obj.pobject_id) then
					obj_ptr := o_locateobj (obj.pobject_id, 0)
				end
				-- perform after abort recovery
				rollback_log.item.recover_after_abort
				rollback_log.remove
			end
			event_stack.wipe_out
			if gc_was_on then
				collection_on
			end
			debug ("transaction")
				timer.stop
				io.putstring ("db_interface.abort finished: ")
				timer.print_time
			end
		ensure
			tran_level_consistent: transaction_level = 0
			unlocked: locks.empty
			events_tossed: event_stack.empty
			actions_done: before_commit_actions.empty
			log_reset: rollback_log.empty
		end;
	
	
	transaction_level : INTEGER
			-- keeps track of nested start/end transactions
	
	
	increment_transaction_level is
		do
			transaction_level := transaction_level + 1
		end
	
	decrement_transaction_level is
		require
			in_a_transaction: transaction_level >= 0
		do
			transaction_level := transaction_level - 1
		end

	
feature {DB_GLOBAL_INFO}

	
	start_transaction is
			-- Start a new transaction
		do
			increment_transaction_level
			debug ("transaction")
				io.putstring ("start_transaction --> level = ")
				io.putint (transaction_level)
				io.new_line
			end
		end
	
	events_active: BOOLEAN
			-- true if event notification is turned on
	
	set_events_active (value: BOOLEAN) is
		do
			events_active := value
		end

	event_stack: SE_STACK[DB_EVENT]
			-- stack of events to be publshed at commit

	publish_db_event (event: DB_EVENT) is
		do
			if transaction_level > 0 then
				event_stack.put (event)
			else
				if db_event_publisher /= Void then
					db_event_publisher.publish_event (event)
				end
			end
		end

	db_event_publisher: DB_EVENT_PUBLISHER
			-- objects that publishes database events

	set_db_event_publisher (new_publisher: DB_EVENT_PUBLISHER) is
		do
			db_event_publisher := new_publisher
		end
	
	end_transaction is
			-- end transaction. If level is zero then commit
		do
			decrement_transaction_level
			if transaction_level = 0 then
				commit
			end
			debug ("transaction")
				io.putstring ("end_transaction --> level = ")
				io.putint (transaction_level)
				io.new_line
			end
		end


	fetch_closure (oid : INTEGER; depth : INTEGER) is
			-- Fetch closure of objects from the object with id "oid" into the db cache.
			-- "depth" specifies how deep the retrieval is
			-- (-1 gives the entire closure)
		require
			id_ok : oid /= 0;
			depth_ok: depth >= -1
		local
			obj_vstr : POINTER
		do
			obj_vstr := c_build_int_vstr (obj_vstr, oid);
			if obj_vstr /= default_pointer then
				obj_vstr := o_getclosure (obj_vstr, default_pointer, depth,
							  0, False, 0);
				debug
					io.putstring ("fetched -->>");
					io.putint (c_sizeofvstr (obj_vstr));
					io.new_line
				end
			end
		end

	ei_class : EI_CLASS is
		once
			!!Result.make;
		end;
	
	last_error : INTEGER is
		do
			Result := c_get_error
		end;
	
feature -- batch

	start_batch is
		do
			start_transaction
			list_manager.start_batch
			-- Disable generation of events during batch processing
			events_active := False
		end

	end_batch is
		local
			persistent_roots: PERSISTENT_ROOTS
		do
			!!persistent_roots
			persistent_roots.store_differences
			-- commit
			end_transaction
			-- Enable events processing after batch
			events_active := True
			io.putstring (">>> Ending batch - commit done %N")
		end

	list_manager: PLIST_MANAGER is
		once
			!!Result.make
		end

	flush_all is
		local
			persistent_roots: expanded PERSISTENT_ROOTS
			q_results: expanded QUERY_RESULTS_MANAGER
		do
			persistent_roots.flush_all_roots
			list_manager.flush
			list_manager.end_batch
			q_results.wipe_all_result
--			key_object_cache.flush
			operation_context_stack.wipe_out
			io.putstring ("Flush all, calling full_collect%N")
			full_collect
			io.putstring ("Flush all, calling full_coalesce%N")
			full_coalesce
		end

	view_table: VIEW_TABLE is
		once
			!!Result
		end

end -- DB_INTERFACE_INFO

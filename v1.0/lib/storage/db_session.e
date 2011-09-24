-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- DB_SESSION - manage a session with databases
--

class DB_SESSION
	
inherit

	DB_GLOBAL_INFO
	VERSANT_EXTERNALS
	DB_CONSTANTS

feature -- session management
	
	active : BOOLEAN is
			-- true, if session is active 
		do
			Result := db_interface.session_is_active
		end;
	
	session_database: DATABASE is
			-- the session database - we connected to thisone first
		do
			Result := db_interface.session_database
		end

	begin (db_name : STRING) is
			-- begin a database session
		require
			session_not_active: not active;
			db_name_ok: db_name /= Void;
		local
			handler : DEFAULT_VERSION_MISMATCH_HANDLER
			null_handler: NULL_VERSION_MISMATCH_HANDLER
			ldb: DATABASE
		do
			-- to fool the dead code removal create a garbage "null_handler"
			!!null_handler
			if c_begin_session (default_pointer, $(db_name.to_c), default_pointer) /= 0 then
				check_error;
			end;
			db_interface.set_session_is_active (True)
			if db_interface.version_mismatch_handler = Void then
				!!handler
				db_interface.set_version_mismatch_handler (handler)
			end
			ldb := db_interface.defined_databases.item (db_name)
			if ldb = Void then
				!!ldb.make (db_name)
			end
			-- by default we don't lock anything
			o_setdefaultlock (db_no_lock);
			ldb.set_connected (True);
			db_interface.set_current_database (ldb)
			db_interface.set_session_database (ldb)
			db_interface.active_databases.add (ldb)
			db_interface.defined_databases.put (ldb, ldb.name)
		ensure
			is_active : active
		end;

	finish is
			-- End session. Commit current transaction
		require
			is_active: active
		do
			if o_endsession (default_pointer, default_pointer) /= 0 then
				except.raise ("db_session: end sesion failed");
			end;
			db_interface.set_session_is_active (False);			
			db_interface.active_databases.remove (session_database);
		ensure
			not_active : not active
		end; -- finish

	database_cache_in_use : INTEGER is
			-- database cache kilobytes used
		require
			is_active: active
		local
			tmp: INTEGER
		do
			if db_interface.o_getcacheused ($tmp) /= 0 then
				check_error
			end
			Result := tmp
		end
	
feature -- databases

	default_db : DATABASE is
			-- the name of the default db
		obsolete "Use 'session_database'"
		do
			Result := session_database
		end

	current_database : DATABASE is
			-- Current active database. New objects are
			-- created in this database
		do
			Result := db_interface.current_database
		end

	set_current_database (db : DATABASE) is
			-- Change current database
		require
			db_ok: (db /= Void) and then (db.is_connected)
		do
			db_interface.set_current_database (db);
		end
	
	unset_current_database is
			-- go back to previous "current database"
		do
			if db_interface.db_stack.count > 1 then
				db_interface.unset_current_database
			end
		end
	
	find_connected_database (db_name : STRING) : DATABASE is
			-- Find a connected database
		require
			db_name_ok: db_name /= Void
		do
			Result := db_interface.active_databases.item_by_key (db_name)
		ensure
			(Result /= Void) implies (Result.is_connected)
		end
	
	find_database (db_name : STRING) : DATABASE is
			-- Find a defined database
		require
			db_name_ok: db_name /= Void
		do
			Result := find_connected_database (db_name)
			if result = Void then
				Result := db_interface.defined_databases.item (db_name)
			end
		end

	database_names : ARRAY [STRING] is
			-- Return the names of all connected databases
		local
			i: INTEGER
			db: DATABASE
		do
			!!Result.make (1, db_interface.active_databases.count);
			from i := 1 until i > db_interface.active_databases.count
			loop
				db := db_interface.active_databases.i_th(i)
				Result.put (db.name, i)
				i := i + 1
			end
		end

feature -- error information

	last_error : INTEGER is
			-- Last database error
		do
			Result := c_get_error
		end;

	error_msg  : STRING is
			-- error message corresponding to "last_error"
		local
			tmp: ANY
		do
			!!Result.make (100);
			tmp := Result.to_c
			if db_interface.o_geterrormessage (last_error, $(tmp), Result.capacity) = 0
			 then
				Result.from_c ($tmp)
			else
				Result := "Versant error"
			end
		end


feature -- transaction

	start_transaction is
			-- Start a transaction. No commits until
			-- "end_transaction" is called
		require
			is_active: active
		do
			db_interface.start_transaction
		ensure
			in_transaction: in_transaction	
		end
	
	end_transaction is
			-- "commit" and go into implicit_commit mode
		require
			is_active: active
		do
			db_interface.end_transaction
		end

	end_transaction_with_context (context: POBJECT) is
			-- store the contenxt and end the transaction
		require
			is_active: active
		do
			context.store_difference
			db_interface.end_transaction
		end

	in_transaction: BOOLEAN is
			-- Are we inside a transaction?
		do
			Result := db_interface.transaction_level > 0
		end
	
	abort_transaction is
			-- abort current transaction
		require
			is_active: active
			transaction_active: in_transaction
		do
			db_interface.abort
			-- Zero out transaction level
			from 
			until db_interface.transaction_level = 0
			loop
				db_interface.decrement_transaction_level
			end
		ensure
			not in_transaction
		end
	
	add_deferred_action (action: DEFERRED_DB_ACTION) is
			-- add an action to be done just be fore the next commit. 
			-- This action will be performed only once, it has to be 
			-- re-added for the next transaction
		require
			action_valid: action /= Void
		do
			db_interface.before_commit_actions.put (action)
		end				  


feature -- event notification

	publish_db_event (transaction_name: STRING; object: POBJECT) is
			-- publish a db_event. If we are in a middle of a 
			-- transaction the event is saved and it's sent out after 
			-- the commit
		require
			is_active: active
			name_ok: transaction_name /= Void
		local
			event: DB_EVENT					
		do
			if db_interface.events_active then
				if object /= Void then
					!!event.make (transaction_name, object)
					db_interface.publish_db_event (event)
				end
			end
		end

	set_db_event_publisher (new_publisher: DB_EVENT_PUBLISHER) is
		do
			db_interface.set_db_event_publisher (new_publisher)
		end

	event_notification_active: BOOLEAN is
		do
			Result := db_interface.events_active
		end
	
	
feature -- version mismatch handling	
	
	set_version_mismatch_handler (new_handler : VERSION_MISMATCH_HANDLER) is
			-- Define new handler for version mismatch errors
		do
			db_interface.set_version_mismatch_handler (new_handler)
		end
	
	current_mismatch_handler: VERSION_MISMATCH_HANDLER is
			-- currently defined handler for versin mismatches
		do
			Result := db_interface.version_mismatch_handler
		end
	
	version_mismatch_list: FAST_LIST [POBJECT] is
			-- List of objects whose versions were out of
			-- sync during the last "store_difference" operation
		do
			Result := db_interface.mismatch_list
		end

feature -- retrieval

	retrieve_object (logical_id : STRING) : POBJECT is
			-- Retrieve an object by it's LOID
		require
			loid_ok: logical_id /= Void
		local
			object_id : INTEGER;
			tmp : ANY;
			err : INTEGER;
			context: DB_OPERATION_CONTEXT
			exists: BOOLEAN
		do
			-- First create an internal object_id from loid
			tmp := logical_id.to_c;
			object_id := c_scan_loid ($tmp);
			if (object_id /= 0) then
				-- Make sure the object actually
				-- exists in the database here
				exists := True
				if not is_pinned (object_id)  then
					if o_locateobj (object_id, 0) /= default_pointer then
						err := o_unpinobj (object_id, 0)
					else
						exists := False
					end
				end
				if exists then
					!!context.make_for_retrieve
					db_interface.operation_context_stack.put (context)
					Result := db_interface.rebuild_eiffel_object (object_id);
					context.mark_objects_not_in_progress 
					db_interface.operation_context_stack.remove
				end
			end;
		end; -- retrieve_object
	
	retrieve_class (db_class_name : STRING) : PCLASS is
			-- Retrieve a class by its name. We look for
			-- the class in the current database.
		require
			class_name_ok: db_class_name /= Void;
		do
			Result := db_interface.find_class (db_class_name);
		end;
	

feature -- batch

	start_batch is
		require
			is_active: active
		do
			db_interface.start_batch
		end
	
	end_batch is
		require
			is_active: active
		do
			db_interface.end_batch
		end
	
	flush_all is
		require
			is_active: active
		do
			io.putstring ("OBJECT TABLE.count before flush = ")
			io.putint (db_interface.object_table.count)
			io.new_line
			db_interface.flush_all
			io.putstring ("OBJECT TABLE.count after flush = ")
			io.putint (db_interface.object_table.count)
			io.new_line
		end
	
	

end -- DB_SESSION

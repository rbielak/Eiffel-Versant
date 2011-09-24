-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- This class represents a connection to a database
--

class DATABASE
	
inherit
	
	DB_GLOBAL_INFO

creation
	
	make

feature -- connection
	
	is_connected: BOOLEAN;
			-- True if we are connected to the database

	connect is
			-- connect to the database
		require
			name_specifed: name /= Void
			not_connected: not is_connected
		local
			err: INTEGER
		do
			err := db_interface.o_connectdb ($(name.to_c), 0);
			if err /= 0 then
				io.put_string ("*** Failed to connect to database: ")
				io.put_string (name)
				io.new_line
				check_error
			end;
			is_connected := True
			db_interface.active_databases.add (Current)
			db_interface.defined_databases.put (Current, name)
		ensure
			connected: is_connected
		end
	
	connect_and_set_rights (rights_set : ROOT_RIGHTS_SET) is
			-- connect and set rights for persistent roots
		require
			name_specifed: name /= Void
			not_connected: not is_connected
		do
			connect
			compute_rights_stamps (rights_set)
		ensure
			connected: is_connected
			rights_defined: rights_stamp_set /= Void
		end
	
	disconnect is
			-- Disconnect from the database
		require
			connected: is_connected
		local
			err : INTEGER;
		do
			err := db_interface.o_disconnectdb ($(name.to_c));
			if err /= 0 then
				check_error
			end
			is_connected := False
			db_interface.active_databases.remove (Current);
		ensure
			not_connected: not is_connected
		end


feature -- names and attributes 
	
	name: STRING;
			-- Name of this database
	
	name_without_server: STRING is
		require
			name_ok: name /= Void
		local
			at_pos: INTEGER
		do
			Result := clone (name)
			at_pos := Result.index_of ('@', 1);
			if at_pos > 0 then
				Result.head (at_pos - 1)
			end
		end

	
	is_closed: BOOLEAN is
			-- Is this database closed? (i.e. it doesn't reference
			-- any objects in other dbs)
		do
			if database_root /= Void then
				Result := database_root.closed
			end
		end

	mark_database_closed is
		require
			is_connected: is_connected
		do
			if database_root = Void then
				create_db_root
			end
			hidden_db_root.set_closed (True)
			hidden_db_root.store_shallow
		ensure
			database_root_not_void: database_root /= Void
			db_consistent: database_root.database = Current
		end
	
	
	is_production: BOOLEAN is
			-- Is this a production database
		do
			if database_root /= Void then
				Result := database_root.production
			end
		end

	mark_database_as_production is
		require
			is_connected: is_connected
		do
			if database_root = Void then
				create_db_root
			end
			hidden_db_root.set_production (True)
			hidden_db_root.store_shallow
		ensure
			database_root_not_void: database_root /= Void
			db_consistent: database_root.database = Current
		end

	
	database_id: INTEGER is
			-- Database ID of this database
		require
			connected: is_connected
		do
			if database_root /= Void then
				Result := database_root.database_id
			end
		end

	database_owner: STRING is
			-- the DBA user
		require
			connected: is_connected
		do
			Result := db_interface.c_get_db_owner ($(name.to_c))
		end

	database_root: DATABASE_ROOT is
		require
			is_connected: is_connected
		local
			query : DB_QUERY [DATABASE_ROOT]
			name_pred : DB_STRING_PREDICATE
		do
			if hidden_db_root = Void then
				-- Do this only if DATABASE_ROOT schema is in the database
				if find_class_id ("DATABASE_ROOT") /= 0  then
					!!query.make ("DATABASE_ROOT");
					!!name_pred.make ("name", name_without_server);
					query.add_predicate (name_pred)
					query.set_database (Current)
					query.execute;
					if query.last_result /= Void then
						if query.last_result.count > 1 then
							except.raise ("More than one database_root")
						end
						hidden_db_root := query.last_result.i_th (1);
					end
					if hidden_db_root /= Void then
						-- make sure the database in
						-- database_info is same as we are
						if hidden_db_root.database /= Current then
							except.raise ("Database info invalid")
						end
					else
						-- create it
						create_db_root
					end
				end
			end
			Result := hidden_db_root
		end

	
feature -- import and migration

	imported (item: POBJECT; new_root_id: INTEGER) : like item is
			-- Move the object structure starting at
			-- "item" into the current database
		require
			item_exits: item /= Void
			item_persistent : item.pobject_id /= 0
		local
			action : IN_DB_CLOSURE_ACTION
			new_objects, old_objects : TWO_WAY_LIST [POBJECT]
			new_object_index : ARRAY [POBJECT]
			the_object, new_ref, old_ref : POBJECT
			i, old_pos : INTEGER
			context: DB_OPERATION_CONTEXT
		do
			!!context.make_for_store
			db_interface.operation_context_stack.put (context)
			db_interface.set_current_database (item.database)
			db_interface.start_transaction
			-- Compute the closure
			io.put_string ("--> Computing closure %N");
			!!action.make (item)
			closure_scanner.traverse (item, action);
			-- Copy the objects
			!!new_objects.make
			old_objects := closure_scanner.closure
			io.put_string ("--> Copying "); 
			io.putint (old_objects.count)
			io.put_string (" objects %N");
			-- Array index to make reference fixup faster
			!!new_object_index.make (1, old_objects.count)
			from 
				old_objects.start
				i := 1
			until 
				old_objects.off
			loop
				new_objects.extend (old_objects.item.twin)
				new_object_index.put (new_objects.last, i)
				old_objects.forth
				i := i + 1
			end
			-- Fix up references in new objects and create
			-- new objects in the database
			io.put_string ("--> Fixing up references %N");
			db_interface.set_current_database (Current)
			from new_objects.start
			until new_objects.off
			loop
				the_object := new_objects.item
				the_object.set_root_id (new_root_id)
				if the_object.pobject_id = 0 then
					the_object.make_persistent
				end
				from i := 1
				until i > the_object.ref_count
				loop
					old_ref := the_object.ith_ref (i)
					if old_ref /= Void then 
						old_pos := old_ref.closure_position
						if (old_pos > 0) then
							new_ref := new_object_index.area.item (old_pos - 1)
							the_object.set_ith_ref (i, new_ref)
						end
					end
					i := i + 1
				end
				new_objects.forth
			end
			-- Store new objects in the current database
			io.put_string ("--> Storing %N");
			from new_objects.start
			until new_objects.off
			loop
				new_objects.item.store_shallow_obj (context)
				new_objects.forth
			end
			context.mark_objects_not_in_progress 
			db_interface.operation_context_stack.remove			
			Result := new_objects.first
			-- Cleanup at the end
			closure_scanner.wipe_out_closure
			db_interface.unset_current_database
			db_interface.end_transaction
			db_interface.unset_current_database
		ensure
			result_persistent: Result.pobject_id /= 0
			result_in_db: Result.database = Current
		end
	
	migrate (root: PERSISTENCY_ROOT [POBJECT]) is
			-- Move a persistency root into this database
		require
			root_in_other_db: root.root_database /= Current
		local
			root_closure: LIST [POBJECT]
			action: IN_ROOT_CLOSURE_ACTION
			original_database: DATABASE
			move_vstr: VSTR
			not_moved: POINTER
			err: INTEGER
			new_root_id: INTEGER
		do
			original_database := root.root_database
			-- first compute the closure of the root
			io.put_string ("--> Computing closure%N")
			!!action.make (root.root_info)
			closure_scanner.traverse (root.root_info, action)
			root_closure := closure_scanner.closure
			-- now create a Vstr of objects to move
			!!move_vstr.make (default_pointer)
			from 
				root_closure.start
			until
				root_closure.off
			loop
				move_vstr.extend_integer (root_closure.item.pobject_id)
				root_closure.forth
			end
			db_interface.start_transaction
			io.put_string ("--> Migrating ")
			io.putint (move_vstr.integer_count)
			io.put_string (" objects. %N")
			-- move the objects to this database
			err := db_interface.o_migrateobjs (move_vstr.area,
										$(original_database.name.to_c),
										$(name.to_c),
										$not_moved)
			check_error
			io.putstring ("--> Fixing objects. %N")
			-- move root_info
			original_database.remove_persistency_root (root.root_info)
			-- Reset PCLASS and root_id of ROOT_INFO object
			root.root_info.reset_pobject_class
			root.reset_database
			add_persistency_root (root.root_info)
			new_root_id := root.root_info.pobject_root_id
			-- reset the root ID of all the objects in the closure
			from
				root_closure.start
			until
				root_closure.off
			loop
				root_closure.item.reset_pobject_class
				root_closure.item.set_root_id (new_root_id)
				root_closure.forth
			end
			-- store
			root.root_info.store_difference
			db_interface.end_transaction
			closure_scanner.wipe_out_closure
			io.putstring ("--> Migration finished %N")
		ensure
			root_in_this_db: root.root_database = Current
		end
	
feature -- schema access
	
	find_class_id (class_name : STRING) : INTEGER is
			-- Retrieve class ID of a class in this
			-- database (return 0 if no such class)
		do
			Result := db_interface.c_locateclass ($(class_name.to_c), $(name.to_c))
			-- Do not put "check_error" here as various schema tools
			-- will break. This routine gives us a way to see if a
			-- class exists in the schema
		end
	
	has_class (class_id : INTEGER; class_name : STRING) : BOOLEAN is
			-- Does the class with the specific name and
			-- object id?
		do
			Result := class_id = find_class_id (class_name)
		end

	find_class (class_name: STRING): PCLASS is
		require
			class_name_not_void: class_name /= Void
		local
			class_id: INTEGER
		do
			class_id := find_class_id (class_name)
			Result := db_interface.find_class_by_class_id (class_id)
		end

feature -- persistent roots
	
	root_count: INTEGER is
			-- count of roots in this database
		do
			if (database_root /= Void) and then (database_root.roots /= Void) then
				Result := database_root.roots.count
			end
		end

	root_names: ARRAY[STRING] is
			-- names of the persistent roots in this database
		local
			i: INTEGER
			root_list : PLIST[ROOT_INFO]
		do
			root_list := database_root.roots
			!!Result.make (1, root_list.count)
			from
				i := 1
			until
				i > root_list.count
			loop
				Result.put (root_list.i_th(i).root_name.twin, i)			   
				i := i + 1
			end
		end
	
feature {DATABASE, ROOT_SERVER}
	
	remove_persistency_root (root: ROOT_INFO) is
		require
			valid: root /= Void
			in_db: root.database = current
		do
			database_root.roots.remove_item (root)
			database_root.roots.store_shallow
		end
	
feature {PERSISTENCY_ROOT, ROOT_SERVER}	

	add_persistency_root (root : ROOT_INFO) is
			-- Add a persistency root to the list of roots
			-- in this database
		require
			root_ok: (root /= Void) 
			right_database: (root.pobject_id = 0) or else (root.pobject_class.db = Current)
		local
			new_root_index: INTEGER
			lroot_count: INTEGER
		do
			if database_root = Void then
				create_db_root
			end
			-- Verify that the root doesn't already exist
			if find_persistency_root_id (root.root_name) /= 0 then
				except.raise ("Root name not unique")
			end
			-- Assign root ID
			lroot_count := database_root.roots.count
			if lroot_count = 0 then
				new_root_index := 1
			else
				new_root_index := database_root.roots.item (lroot_count).root_index + 1
			end
			root.assign_new_root_id (new_root_index + database_id * db_interface.max_roots_per_db)
			root.set_root_index (new_root_index)
			root.store_difference
			-- Append to the list of roots in this database
			database_root.roots.extend (root)
			database_root.roots.store_shallow
		end
	
	
	find_persistency_root_id (root_name : STRING) : INTEGER is
			-- Find root ID by name
		require
			valid_name: root_name /= Void
		do
			if database_root = Void then
				create_db_root
			end
			if root_query = Void then
				!!root_query.make ("root_name = $1");
			end
			root_query.execute (database_root.roots, <<root_name>>);
			if root_query.last_result /= Void then
				-- Result := root_query.last_result.i_th(1).pobject_root_id
				Result := root_query.last_result.i_th_object_id(1)
			end
		end


	
feature {PERSISTENT_ROOTS, PERSISTENCY_ROOT, DB_INTERFACE_INFO, POBJECT}	

	rights_stamp_by_id (root_id : INTEGER) : INTEGER is
		local
			index : INTEGER
			db_id : INTEGER
		do
			if (rights_stamp_set = Void) or (root_id = 0) then
				Result := db_interface.read_write_display_allowed
			else
				db_id := root_id // db_interface.max_roots_per_db
				index := root_id \\ db_interface.max_roots_per_db
				if db_id /= database_id then
					io.put_string ("***Error: root_id in object=");
					io.putint (root_id);
					io.put_string (". db_id=");
					io.putint (db_id);
					io.put_string (" but object is in dbid=");
					io.putint (database_id)
					io.new_line
					except.raise ("Wrong db ID");
				else
					Result := rights_stamp_set.rights_stamp_by_index (index)
				end
			end
		end

	compute_rights_stamps (rights_set : ROOT_RIGHTS_SET) is
		do
			io.put_string ("Computing rights stamps for database=");
			io.put_string (name);
			io.new_line;
			!!rights_stamp_set;
			rights_stamp_set.compute_rights_stamps (rights_set, database_root.roots)
		end


	update_rights_stamps (rights_set: ROOT_RIGHTS_SET) is
		require
			rights_set_valid: rights_set /= Void
		do
			rights_stamp_set.update_rights_stamps (rights_set, database_root.roots)
		end


feature {DB_SESSION}
	
	set_connected (new_value : BOOLEAN) is
		do
			is_connected := new_value
		end

feature {DB_QUERY}
	
	db_select (class_name : STRING; 
		   predicates_pointer : POINTER; 
		   include_descendants : BOOLEAN) : POINTER is
		do
			Result := db_interface.c_db_select ($(class_name.to_c), 
												$(name.to_c),
												include_descendants, 0,
												predicates_pointer);
			check_error
		end
	
feature {VERSANT_DB_PATH_QUERY, DB_PATH_QUERY, INTERNAL_QUERY}	
	
	db_class_select (class_name : STRING; predicate_pointer: POINTER) : POINTER is
			-- Do a path select on a specific class and
			-- descendants. Don' lock anything
		do
			Result := db_interface.c_pathselect ($(class_name.to_c),
												 $(name.to_c),
												 predicate_pointer,
												 0, default_pointer)
			if db_interface.last_error = db_interface.path_select_multi_db_error then
				except.raise ("path_select - multidb error")
			elseif db_interface.last_error = db_interface.weak_link_query_error then
				except.raise ("weak_Link query error")
			else
				check_error
			end
		end
	
	db_plist_select (predicate_pointer: POINTER; list : PLIST [POBJECT]) : POINTER is
		require
			list_persistent: list.pobject_id /= 0
		do
			Result := db_interface.c_pathselect (default_pointer,
												 $(name.to_c),
												 predicate_pointer,
												 list.pobject_id, 
												 $(area_str.to_c))
			check_error
		end
	
	area_str: STRING is "area"

feature {NONE}	
	
	
	rights_stamp_set : RIGHTS_STAMP_SET
			-- Set of rights stamps for roots in this database


	make (db_name : STRING) is
		require
			name_ok: db_name /= Void
		do
			name := db_name.twin
		ensure
			name_there : name /= Void;
			not_connected: not is_connected
		end;
	
	hidden_db_root : DATABASE_ROOT
			-- reference to database root object, if one exists
	
	create_db_root is
		do
			db_interface.set_current_database (Current)
			-- For newly created roots the database ID will be the ID
			-- of the current database.
			!!hidden_db_root.make (name_without_server, 
								   db_interface.c_get_db_id ($(name.to_c)))
			hidden_db_root.store
			db_interface.unset_current_database
		ensure
			db_root_exists: (hidden_db_root /= Void) and 
			 then (hidden_db_root.pobject_id /= 0)
			db_consitent: hidden_db_root.database = Current
		end
	
	root_query : SELECT_QUERY [ROOT_INFO];

	
	closure_scanner : POBJECT_CLOSURE_SCANNER is
		once
			!!Result.make
		end


invariant
	
	db_name_there: name /= Void

end -- DATABASE

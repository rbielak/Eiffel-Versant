-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "Create and retrieve persistent roots from a database"

class ROOT_SERVER
	
inherit
	
	DB_GLOBAL_INFO

creation
	
	make

feature
	
	last_created : PERSISTENCY_ROOT [POBJECT]
			-- Root created last
	

	create_new_root (db : DATABASE; new_name : STRING; contents_type: STRING; 
			 manager_gen : STRING; new_ui_type : STRING;
			 restricted_classes : ARRAY[STRING]; 
			 register : BOOLEAN) is
			-- Create a new root in the soecified DB
		require
			db_ok: (db /= Void) and then db.is_connected
			root_name_ok: new_name /= Void
			contents_type_ok: contents_type /= Void
			manager_gen_ok: manager_gen /= Void
		local
			ri : ROOT_INFO
			new_root : PERSISTENCY_ROOT [POBJECT]
		do
			-- Make a root_info object to store in the database
			ri := create_new_root_info (new_name, contents_type, manager_gen, 
							 new_ui_type, restricted_classes, register);
			-- Make the corresponding Eiffel object
			new_root := make_root_object (ri);
			if new_root = Void then
				except.raise ("Cannot create Eiffel root");
			end
			-- Store in the designated database
			store_new_root_info (db, ri);
			set_up_root_object (ri, new_root);
			last_created := new_root
		ensure
			root_there: (last_created /= Void) implies last_created.available
		end

	remove_root_by_id (root_id: INTEGER) is
			-- remove a root from the database
		require
			root_id_valid: root_id /= 0
		local
			ri: ROOT_INFO
			db: DATABASE
		do
			ri := find_root_info_by_id (root_id)
			if ri /= Void then
				db := ri.database
				db.remove_persistency_root (ri)
			end
		ensure
			removed: root_by_id (root_id) = Void
		end
	
	root_by_name (root_name : STRING) : PERSISTENCY_ROOT [POBJECT] is
			-- Get a root from any database with the given
			-- name. If more than one is found the first
			-- one will be returned
		require
			root_name_ok: root_name /= Void			
		local
			ri : ROOT_INFO
			temp : BOOLEAN
		do
			-- Find root info in any database
			ri := find_root_info (root_name, Void);
			if ri /= Void then
				if ri.eiffel_root /= Void then
					Result := ri.eiffel_root
				else
					Result := make_root_object (ri);
					set_up_root_object (ri, Result);
				end
			end
		ensure
			correct_root: (Result /= Void) implies root_name.is_equal (Result.root_name)
		end

	named_root_by_name (root_name: STRING; contents_type: STRING): NAMED_MAN [NAMED_MANAGEABLE] is
			-- retrieve a NAMED_MAN by name. If "contents_type" is 
			-- specified then set the typing criteria for the get 
			-- query in this MAN.
		require
			root_name_ok: root_name /= Void
		do
			Result ?= root_by_name (root_name)
			if contents_type /= Void then
				Result.set_typing_criteria (contents_type)
			end
		end
	
	root_from_db (db : DATABASE; root_name : STRING) : PERSISTENCY_ROOT [POBJECT] is
			-- Get a root from a specific database
		require
			db_ok: (db /= Void) and then db.is_connected
			root_name_ok: root_name /= Void 
		local
			ri : ROOT_INFO
		do
			ri := find_root_info (root_name, db);
			if ri /= Void then
				if ri.eiffel_root /= Void then
					Result := ri.eiffel_root
				else
					Result := make_root_object (ri);
					set_up_root_object (ri, Result);				
				end
			end
		ensure
			correct_root: (Result /= Void) implies 
						(root_name.is_equal (Result.root_name) and
							(db = Result.root_database))
		end
	
	root_by_id (root_id : INTEGER) : PERSISTENCY_ROOT [POBJECT] is
			-- get a root by root_id
		require
			root_id_ok: root_id > 0
		local
			ri: ROOT_INFO
		do
			ri := find_root_info_by_id (root_id)
			if ri.eiffel_root /= Void then
					Result := ri.eiffel_root
			else
				Result := make_root_object (ri);
				set_up_root_object (ri, Result);				
			end
		ensure
			correct_root: (Result /= Void) implies (root_id = Result.root_id)
		end
	
	
	root_pobject_id_by_name (root_name: STRING): INTEGER is
		require
			root_name_valid: root_name /= Void
		local
			i: INTEGER
			db: DATABASE
			root_info_pobject_id: INTEGER
		do
			from i := 1
			until (root_info_pobject_id /= 0) or (i > db_interface.active_databases.count)
			loop
				db :=  db_interface.active_databases.i_th (i)
				root_info_pobject_id := db.find_persistency_root_id (root_name)
				i := i + 1
			end
			Result := root_info_pobject_id
		end
	
	root_name_by_id (root_id: INTEGER): STRING is
			-- get name of a root by ID
		require
			root_id_ok: root_id > 0
		local
			db_id, root_inde, root_info_oid, root_index, i: INTEGER
			done: BOOLEAN
			db: DATABASE
		do
			-- Get the name of the root, but be careful
			-- and retrieve the minimal amount of stiff in
			-- to Eiffel
			db_id := root_id // db_interface.max_roots_per_db
			root_index := root_id \\ db_interface.max_roots_per_db
			-- Find the right database first
			from 
				i := 1
			until 
				done or (i > db_interface.active_databases.count)
			loop
				db :=  db_interface.active_databases.i_th (i)
				done := db.database_id = db_id
				i := i + 1
			end
			-- If we got the database then retrieve root_info
			if done then
				root_info_oid := db.database_root.roots.i_th_object_id (root_index)
				Result := db_interface.get_db_string_attr (root_info_oid, $(("root_name").to_c))
				check_error
			end

		end
	
	list_by_name (root_name : STRING): PERSISTENCY_ROOT [POBJECT] is
		require
			root_name_exists: root_name /= Void
		local
			Fo_version_name: STRING
			root: PERSISTENCY_ROOT [POBJECT]
			ri: ROOT_INFO
		do
			!!Fo_version_name.make (root_name.count + 3)
			Fo_version_name.append ("Fo_")
			Fo_version_name.append (root_name)
			-- find the root to get element type name
			root := root_by_name (root_name)
			if root = Void then
				root := root_by_name (Fo_version_name)
			end
			if root /= Void then
				ri := root.root_info
				Result := root_group_by_names (root_name, ri.root_contents_type,
											   <<Fo_version_name, root_name>>)
			end
		end
	
	root_group_by_names (new_root_name: STRING; item_type: STRING;
						 names: ARRAY [STRING]): PERSISTENCY_ROOT [POBJECT] is
			-- Create a group of roots, the first root is the target
			-- for "add_item". "item_type" must be an ancestor of of 
			-- types in the mans
		require
			root_name_exists: new_root_name /= Void;
			item_type_exists: item_type /= Void
			names_exist: (names /= Void) and then (names.count > 0)
		local
			i: INTEGER
			root_name: STRING
			roots: ARRAY [like root_by_name]
			named_roots: ARRAY [NAMED_MAN [NAMED_MANAGEABLE]]
			one_named_root: NAMED_MAN [NAMED_MANAGEABLE]
			one_root: like root_by_name
			root_count, root_named_count: INTEGER
			answer: GROUP_NAMED_MAN [NAMED_MANAGEABLE]
			answer_generator: STRING
			temp: BOOLEAN
		do
			!!roots.make (1, names.count)
			!!named_roots.make (1, names.count)
			from
				i := 1
			until
				i > names.count
			loop
				one_root := root_by_name (names @ i)
				one_named_root ?= one_root
				if one_root /= Void then
					root_count := root_count + 1
					roots.put (one_root, root_count)
				end
				if one_named_root /= void then
					root_named_count := root_named_count+1
					named_roots.put (one_named_root, root_named_count)
				end
				i := i + 1
			end
			if root_named_count > 1 then
				-- create an answer of type GROUP_NAMED_MAN["item_type"]
				item_type.to_upper
				answer_generator := "GROUP_NAMED_MAN["
				answer_generator.append (item_type)
				answer_generator.append ("]")
				answer_generator.to_upper
				-- disable assertion checks
				temp := c_check_assert (False)
				db_interface.ei_class.make_from_name (answer_generator)
				answer ?= db_interface.ei_class.allocate_object
				answer.init (named_roots)
				-- reenable assertion checking
				temp := c_check_assert (temp)
				answer.set_add_target (named_roots @ 1)
				answer.set_name (new_root_name)
				Result := answer
			elseif root_count = 1 then
				-- If there is only one root, just return it
				Result := roots.item (1)
			elseif root_count = 0 then
				-- If there is no root, return void
			else
				-- Print error
				io.putstring ("Warning root_group_by_names: root_count=")
				io.putint (root_count)
				io.putstring (" and root_named_count=")
				io.putint (root_named_count)
				io.putstring (" (")
				io.putstring (new_root_name)
				io.putstring (")%N")
			end
		end

	all_roots_in_database (db: DATABASE): FAST_RLIST [PERSISTENCY_ROOT [POBJECT]] is
		require
			db_not_void: db /= Void
			db_connected: db.is_connected
		local
			ri_list: PLIST [ROOT_INFO]
			i: INTEGER
			ri: ROOT_INFO
			pr: PERSISTENCY_ROOT [POBJECT]
		do
			!!Result.make
			ri_list := db.database_root.roots
			from i := 1
			until i > ri_list.count
			loop
				ri := ri_list.i_th (i)
				if ri.eiffel_root /= Void then
					Result.extend (ri.eiffel_root)
				else
					pr := make_root_object (ri)
					set_up_root_object (ri, pr);
					Result.extend (pr)
				end
				i := i + 1
			end
			
		end



feature {PERSISTENCY_ROOT, MAN_FEEDER}
	
	
	find_root_info (root_name : STRING; db : DATABASE) : ROOT_INFO is
		require
			root_name_ok: root_name /= Void;
			db_ok: (db /= Void) implies db.is_connected
		local
			root_key: STRING
			i: INTEGER
			done: BOOLEAN
			local_db: DATABASE
		do
			if db /= Void then
				root_key := root_name.twin
				root_key.append ("/")
				root_key.append (db.name_without_server)
			else
				root_key := root_name
			end
			-- check the cache
			Result := root_info_cache.item (root_key)
			if Result = Void then
				if db /= Void then
					name_query.set_fixed_database (db);
					name_query.execute (db.database_root.roots, <<root_name>>)
					if name_query.last_result /= Void then
						Result := name_query.last_result.i_th(1);
					end;
				else
					-- DB is Void, go through all connected dbs
					from 
						i := 1
					until 
						done or (i > db_interface.active_databases.count)
					loop
						local_db :=  db_interface.active_databases.i_th (i)
						name_query.set_fixed_database (local_db);
						name_query.execute (local_db.database_root.roots, <<root_name>>)
						if name_query.last_result /= Void then
							Result := name_query.last_result.i_th(1);
							done := True
						end;
						i := i + 1
					end

				end
				if Result /= Void then
					root_info_cache.put (Result, root_key)
				end
			end
		end
	
	
	find_root_info_by_id (root_id : INTEGER) : ROOT_INFO is
		require
			root_id_ok: root_id > 0
		local
			db_id, root_index, root_object_id, i: INTEGER
			db: DATABASE
			done: BOOLEAN
			roots: PLIST [ROOT_INFO]
		do
			db_id := root_id // db_interface.max_roots_per_db
			root_index := root_id \\ db_interface.max_roots_per_db
			-- Find the right database first
			from 
				i := 1
			until 
				done or (i > db_interface.active_databases.count)
			loop
				db :=  db_interface.active_databases.i_th (i)
				done := db.database_id = db_id
				i := i + 1
			end
			-- If we got the database then retrieve root_info
			if done then
				from 
					i := 1
					roots := db.database_root.roots
				until (i > roots.count) or (Result /= Void)
				loop
					-- get the root_index of the i_th root
					root_object_id := roots.i_th_object_id (i)
					-- if roots.i_th (i).root_index = root_index then
					if db_interface.get_db_int_attr (root_object_id, $(root_index_str.to_c)) = root_index then
						Result := roots.i_th (i)
					end
					i := i + 1
				end
				if (Result = Void) or else (Result.pobject_root_id /= root_id) then
					except.raise ("Error retrieving root by root_id")
				end
			end
		end
	
	create_new_root_info (new_name, contents_type, manager_gen, new_ui_type: STRING; 
					restricted_classes : ARRAY [STRING]; 
					register : BOOLEAN) : ROOT_INFO is
		do
			-- Make a root_info object to store in the database
			manager_gen.to_upper;
			!!Result.set_spec (new_name, contents_type, manager_gen, new_ui_type,
					  restricted_classes, register);
		end
	
	store_new_root_info (db : DATABASE; ri : ROOT_INFO) is
		do
			-- Store in the designated database
			db_interface.set_current_database (db);
			db_interface.current_database.add_persistency_root(ri);
			db_interface.set_current_root_id (ri.pobject_root_id)
			ri.store;
			db_interface.unset_current_root_id
			db_interface.unset_current_database
		end
	
feature {NONE}
	
	root_index_str: STRING is "root_index"
		
	root_info_cache: HASH_TABLE [ROOT_INFO, STRING]
			-- Cache of already retrieved roots, indexed
			-- by name

	name_query : SELECT_QUERY[ROOT_INFO] is
		once
			!!Result.make ("root_name = $1")
			Result.set_evaluation_in_client
		end
	
	root_info_generator : STRING is "ROOT_INFO";
	
	make is
		do
			!!root_info_cache.make (100)
		end
	
	
	ei_class : EI_CLASS is
			-- Used to create objects given string as the type
		once
			!!Result.make;
		end;
	
	make_root_object (ri : ROOT_INFO) :  PERSISTENCY_ROOT [POBJECT] is
		local
			temp : BOOLEAN
		do
			temp := c_check_assert (False)
			ei_class.make_from_name (db_interface.view_table.eiffel_view (
						ri.root_man_generator))
			Result ?= ei_class.allocate_object
			temp := c_check_assert (temp)
			if Result = Void then
				io.putstring ("***ERROR: Class: " )
				io.putstring (ri.root_man_generator)
				io.putstring (" is not compiled into the system. %N")
				except.raise ("class not compiled in")
			end
		end
	
	set_up_root_object (ri : ROOT_INFO; root : PERSISTENCY_ROOT [POBJECT]) is
		local
			temp : BOOLEAN
		do
			temp := c_check_assert (False)
			root.set_spec_from_root_info (ri)
			ri.set_eiffel_root (root)
			temp := c_check_assert (temp)
		end


end -- ROOT_SERVER

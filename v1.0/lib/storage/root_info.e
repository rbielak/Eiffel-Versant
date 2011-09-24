-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class ROOT_INFO

inherit
	
	POBJECT

	
creation
	
	set_spec, set_spec_from_root_info

feature

	set_spec_from_root_info (ri: ROOT_INFO) is
		do
			root_name := ri.root_name
			root_man_generator := ri.root_man_generator
			contents := ri.contents
			root_contents_type := ri.root_contents_type
			root_restricted_classes := ri.root_restricted_classes
			root_ui_type := ri.root_ui_type
			register_root := ri.register_root
		end

	set_spec (new_name : STRING; contents_type: STRING; manager_gen : STRING;
			  new_ui_type : STRING; restricted_classes : ARRAY[STRING]; 
			  register : BOOLEAN) is
		require
			name_ok: new_name /= Void;
			contents_type_ok : contents_type /= Void;
			manager_gen_ok: manager_gen /= Void
		local
			i : INTEGER
			contents_list_generator : STRING
			temp: BOOLEAN
		do
			root_name := new_name.twin
			root_man_generator := manager_gen.twin
			contents_list_generator := "CONCURRENT_PLIST[";
			contents_list_generator.append (contents_type); 
			contents_list_generator.append ("]"); 

			temp := c_check_assert (False)
			db_interface.ei_class.make_from_name (contents_list_generator)
			contents ?= db_interface.ei_class.allocate_object
			contents.make (contents_list_generator)
			-- reset assertion flag
			temp := c_check_assert (temp)

--			!!contents.make (contents_list_generator);
			root_contents_type := contents_type.twin
			if new_ui_type /= Void then
				root_ui_type := new_ui_type.twin
			end
			if restricted_classes /= Void then
				root_restricted_classes := "";
				from i := 1
				until i > restricted_classes.count
				loop
					root_restricted_classes.append (restricted_classes @ i)
					if i < restricted_classes.count then
						root_restricted_classes.append ("/")
					end
					i := i + 1
				end
			end
			register_root := register
		ensure
			contents_there: contents /= Void
			name_there: root_name /= Void
			root_man_generator_there: root_man_generator /= Void
		end;
	
	
	contents : CONCURRENT_PLIST [POBJECT];
			-- Objects held by this root

	root_name : STRING;
			-- the name of the root
	
	root_man_generator : STRING 
			-- generator for the Eiffel type of MAN that
			-- manages this root
	
	root_contents_type : STRING 
			-- generator for the type of contents of this root
	
	root_restricted_classes : STRING
			-- names of classes separated by "/"
	
	root_ui_type : STRING
			-- Type for the UI

	register_root : BOOLEAN 
			-- True, if the root is to be registered for store_difference
	
	eiffel_root : PERSISTENCY_ROOT [POBJECT]
			-- Eiffel object that represents this root
	
	set_eiffel_root (proot : PERSISTENCY_ROOT [POBJECT]) is
		do
			eiffel_root := proot
		end
	
	root_index: INTEGER 
			-- index of this root - it is used to construct the root_id

feature {DATABASE}
	
	assign_new_root_id (new_root_id : INTEGER) is
		require
			new_root_id > 0
		do
			pobject_root_id := new_root_id
		end
	
	set_root_index (new_index: INTEGER) is
		require
			new_index > 0
			-- index unique in database
		do
			root_index := new_index
		end

feature {DB_INTERNAL}

	set_contents (new_contents: like contents) is
			-- this routine is only used for special upgrades
		require
			new_contents_not_void: new_contents /= Void
		do
			new_contents.generator.to_upper
			if not new_contents.generator.is_equal (contents.generator) then
				print ("New generator: ")
				print (new_contents.generator)
				print (" Old generator: ")
				print (contents.generator)
				print ("%N")
				except.raise ("generators do not match")
			end
			contents := new_contents
		ensure
			contents_reset: contents = new_contents
		end


end -- ROOT_INFO

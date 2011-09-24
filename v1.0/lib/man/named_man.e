-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "Manage persistent objects with 'name' attribute"
	database: "Versant"

class NAMED_MAN [T -> NAMED_MANAGEABLE]

inherit

	MAN [T]
		rename
			set_spec_from_root_info as man_set_spec_from_root_info
		undefine
			tags, item_from_tag, type_from_tag, generator
		redefine
			index, create_in_memory_index
		end
	
	MAN [T]
		redefine
			set_spec_from_root_info, tags, item_from_tag, type_from_tag,
			generator, index, create_in_memory_index
		select
			set_spec_from_root_info
		end
	

creation {ROOT_SERVER} 

	set_spec_from_root_info
	
feature
	
	ui_type: STRING

	build_ui_type is
		do
			if available then
				if root_info.root_ui_type /= Void then
					ui_type := "NAMED_MAN[";
					ui_type.append (root_info.root_ui_type)
					ui_type.append ("]")
				end
			end
		end -- build_ui_type

	generator: STRING is
		do
			if root_info /= Void then
				Result := root_info.root_man_generator
			else
				Result := "NAMED_MAN[NAMED_MANAGEABLE]"
			end
		end -- generator

	restricted_classes: ARRAY[STRING];


	extract_keys (element: T): ARRAY [ANY] is
		do
			Result := <<element.name>>
		end -- extract_keys

	get_item (lname: STRING): T is
		require
			name_ok: lname /= Void
			read_allowed: read_allowed
		local
			timer: SIMPLE_TIMER
		do
			debug ("man")
				!!timer
				timer.start
			end
			-- THis code is here so that we still get an
			-- exceptions, even if we're running without assertions.
			if not read_allowed then
				crash ("Not allowed to read ");
			end
			if index.has_name (lname) then
				Result := index.item_by_name (lname)
				memorize_item (Result)
			else
				Result := get_query.get_first (contents, <<lname>>)
				if Result /= void then
					index.add (Result)
				end
			end
			debug ("man")
				timer.stop
				io.putstring ("NAMED_MAN(")
				io.putstring (root_name)
				io.putstring(").get_item: ")
				timer.print_time
			end
		ensure then
			(Result /= Void) implies read_allowed
		end -- get_item
	
	is_acceptable (item: T): BOOLEAN is
			-- Acceptable to insert only things with unique names
		do
			Result := not has_item (item.name)
		end
	
	type_from_tag (lname: STRING): STRING is
		local
			t: T
			timer: SIMPLE_TIMER
		do
			debug ("MAN")
				!!timer
				timer.start
			end
			t := index.item_by_name (lname)
			if t = Void then
				if contents.count < 50 then
					get_query.set_evaluation_in_client
				else
					get_query.set_evaluation_in_server
				end
				get_query.execute (contents, <<lname>>)
				if get_query.last_result /= void then
					Result := get_query.last_result.i_th_type (1)
				end
			else
				Result := t.generator
				memorize_item (t)
			end
			debug ("man")
				timer.stop
				timer.print_time
				io.putstring ("NAMED_MAN(")
				io.putstring (root_name)
				io.putstring(").type_from_tag called%N")
			end
		end

	has_item (lname: STRING): BOOLEAN is
		require 
			name_ok: lname /= Void
			read_allowed: read_allowed
		local
			timer: SIMPLE_TIMER
			litem: T
		do
			debug ("man")
				!!timer
				timer.start
			end
			if not read_allowed then
				crash ("Not allowed to read ");
			end
			Result := index.has_name (lname)
			if not Result and not preloaded then
				-- Have to query
				get_query.execute (contents, <<lname>>)
				Result := get_query.last_result /= Void
				if Result then
					-- If item exists add it to the index
					index.add_by_id (get_query.last_result.i_th_object_id (1), <<"name">>)
				end
			end
			debug ("man")
				timer.stop
				io.putstring ("NAMED_MAN(")
				io.putstring (root_name)
				io.putstring(").has_item: ")
				timer.print_time
			end
		ensure then
			(Result /= Void) implies read_allowed
		end -- has_item

	force_item (item: T) is
			-- Replace an item with the same name. If no
			-- such item exists, just add the new one in
		require 
			item_ok: (item /= Void) and then (item.name /= Void)
		local
			other_item: T
		do
			if not (write_allowed and add_allowed) then
				crash ("Not allowed to modify ");
			end
			db_interface.set_current_manager (Current)
			other_item := index.item_by_name (item.name)
			if other_item /= Void then
				contents.remove_item (other_item)
				index.remove_by_name (item.name)
			else
				other_item := get_query.get_first (contents, <<item.name>>)
				if other_item /= Void then
					contents.remove_item (other_item)
				end
			end
			contents.extend (item)
			index.add (item)
			publish (Void)
			db_interface.unset_current_manager
			debug ("man")
				io.putstring ("NAMED_MAN(")
				io.putstring (root_name)
				io.putstring(").force_item called %N")
			end
		ensure 
			has_item: has (item)
		end -- force_item

	tags: BOUNDED_RLIST [STRING] is
		local
			timer: SIMPLE_TIMER
		do
			debug ("man")
				!!timer
				timer.start
			end
			if available then
				Result := contents.tags;
			end
			debug ("man")
				timer.stop
				io.putstring ("NAMED_MAN(")
				io.putstring (root_name)
				io.putstring(").tags: ")
				timer.print_time
			end
		end -- tags

	item_from_tag (tag: STRING): T is
			-- Get item by name
		do
			Result := get_item (tag);
		end -- item_from_tag

	
	get_item_object_id (lname: STRING): INTEGER is
		require
			good_key: lname /= Void
		local
			it: T
		do
			-- This code is here so that we still get an
			-- exceptions, even if we're running without assertions.
			if not read_allowed then
				crash ("Not allowed to read ");
			end
			it := index.item_by_name (lname)
			if it /= Void then
				Result := it.pobject_id
				memorize_item (it)
			else
				get_query.execute (contents, <<lname>>)
				if get_query.last_result /= void then
					Result := get_query.last_result.i_th_object_id (1)
				end
			end
		end

feature {ROOT_SERVER}
	
	
	set_spec_from_root_info (ri : ROOT_INFO) is
		do
			man_set_spec_from_root_info (ri);
			!!get_query.make ("name = $1");
			build_ui_type
		end

feature -- query optimizations

	set_evaluation_in_client is
		do
			get_query.set_evaluation_in_client
		end

	set_evaluation_in_server is
		do
			get_query.set_evaluation_in_server
		end

	set_typing_criteria (class_name: STRING) is
			-- for Man's that are typed too general in the database 
			-- restrict the type used in query
		do
			get_query.set_typing_criteria (class_name)
		end
		

feature {NONE}

	index: NAMED_MAN_INDEX [T]

	get_query : SELECT_QUERY [T];

	
	crash (msg : STRING) is
			-- Crash the MAN with a error message that has
			-- MAN's name
		do
			msg.append (root_name)
			except.raise (msg)
		end

	create_in_memory_index is
		do
			!!index.make (Current)
		end

	
end -- NAMED_MAN

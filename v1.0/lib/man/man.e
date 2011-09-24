-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "General Manager"

deferred class MAN [T->MANAGEABLE]

inherit

	MAN_SPEC [T]
		rename
			set_spec_from_root_info as ms_set_spec_from_root_info
		redefine
			flush
		end
	
	MAN_SPEC [T]
		redefine
			set_spec_from_root_info, flush
		select
			set_spec_from_root_info
		end

feature {MAN}

	index: MAN_INDEX_SPEC [T]
			-- index to entries in this MAN. We use it to avoid queries

feature

	extract_keys (element: POBJECT): ARRAY [ANY] is
		deferred
		end -- extract_keys


	preloaded: BOOLEAN
			-- true if the MAN has been preloaded. When it's 
			-- preloaded no queries need to be done when looking for something

	preload is
			-- preload the index
		do
			index.preload
			preloaded := True
		ensure
			preloaded
		end

	unload is
			-- clear in memory tables and do a garbage collection 
			-- cycle
		local
			m: MEMORY
		do
			print ("Unloading....MAN:")
			print (root_name)
			print ("%N")
			flush
			!!m
			m.full_collect
		ensure
			not preloaded
		end

	check_ownership (element: T): BOOLEAN is
			-- see if the element belongs to this MAN
		require
			element_exists: element /= Void
		do
			Result := element.pobject_root_id = 0 or else element.pobject_root_id = root_id
		end
	
	extend (element: T) is
			-- Add new element to the MAN. Abort if item
			-- with the same keys already there
		require else
			is_available : available
			add_allowed: add_allowed 
		local
			keys_extracted: ARRAY [ANY]
			keys: DB_KEYS
			timer: SIMPLE_TIMER
		do
			debug ("man")
				!!timer
				timer.start
			end
			if not add_allowed then
				except.raise ("Not allowed to add to  MAN");
			end
			if not check_ownership (element) then
				io.putstring ("Trying into insert into the wrong root%N");
				io.putstring ("root_id=");  io.putint (root_id);
				io.new_line;
				io.putstring (element.tagged_out);
				io.new_line;
				except.raise ("Trying to put into wrong root");
			end
			db_interface.set_current_manager (Current)
			keys_extracted := extract_keys (element)
			if has_item_from_keys (keys_extracted) then
				-- Duplicate item, abort
				except.raise ("Inserting duplicate item in MAN")
			else
				-- OK to add
				contents.extend (element)
				!!keys.make_from_array (keys_extracted)
				-- memory_table.put (element, keys)
				index.add_with_keys (element, keys)
				publish (Void)
			end
			db_interface.unset_current_manager
			debug ("man")
				timer.stop
				io.putstring ("MAN(")
				io.putstring (root_name)
				io.putstring(").extend called: ")
				timer.print_time
			end
		ensure then
			item_added: has (element)
		end

	update (element : T) is
			-- Update element that's handled by this manager
		do
			db_interface.set_current_manager (Current)
			element.store_difference
			db_interface.unset_current_manager
		end -- update

	get_query: SELECT_QUERY [T] is
		deferred
		ensure
			not Result.bad_query
		end -- get_query

	has_item_with_keys (item : T) : BOOLEAN is
			-- Check if item with the same keys exists
		require
			item /= Void
		do
			Result := has_item_from_keys (extract_keys (item))
		end

	has_item_from_keys (item_keys: ARRAY[ANY]): BOOLEAN is
		require
			read_allowed: read_allowed
		local
			keys: DB_KEYS
			timer: SIMPLE_TIMER
		do
			debug ("man")
				!!timer
				timer.start
			end
			!!keys.make_from_array (item_keys)
			Result := index.has_keys (keys)
			if not Result and not preloaded then
				Result := get_query.get_first (contents, item_keys) /= Void
			end
			debug ("man")
				timer.stop
				io.putstring ("MAN(")
				io.putstring (root_name)
				io.putstring(").has_item_from_keys: ")
				timer.print_time
			end
		end -- has_item_from_keys

	get_item_from_keys (item_keys: ARRAY[ANY]): T is
		require
			read_allowed: read_allowed
		local
			keys: DB_KEYS
			timer: SIMPLE_TIMER
		do
			debug ("man")
				!!timer
				timer.start
			end
			!!keys.make_from_array (item_keys)
			Result := index.item_by_key (keys)
			if Result = Void then
				Result := get_query.get_first (contents, item_keys)
				if Result /= void then
					index.add_with_keys (Result, keys)
				end
			end
			if Result /= Void then
				memorize_item (Result)
			end
			debug ("man")
				timer.stop
				io.putstring ("MAN(")
				io.putstring (root_name)
				io.putstring(").get_item_from_keys: ")
				timer.print_time
			end
		end -- get_item_from_keys

	has (element: T): BOOLEAN is
			-- See if we have this object in this MAN's cache
		local
			keys: DB_KEYS
			timer: SIMPLE_TIMER
		do
			debug ("man")
				!!timer
				timer.start
			end
			if not read_allowed then
				except.raise ("Not allowed to read this MAN");
			end
			-- If the thing is not presistent, then we
			-- can't have it
			if element.pobject_id /= 0 then
				!!keys.make_from_array (extract_keys (element))
				Result := index.has_keys (keys)
				if not Result then
					Result := contents.has (element)
				end
			end
			debug ("man")
				timer.stop
				io.putstring ("MAN(")
				io.putstring (root_name)
				io.putstring(").has_element: ")
				timer.print_time
			end
		end -- has

	remove_item (item: T) is
			-- From RLIST.
		local
			keys: DB_KEYS
			item_exists : BOOLEAN
		do
			if not delete_allowed then
				except.raise ("Not allowed to delete from this MAN");
			end
			if item.pobject_id /= 0 then
				!!keys.make_from_array (extract_keys (item))
				item_exists := index.has_keys (keys) or else contents.has (item)
				if item_exists then
					contents.remove_item (item)
					if index.has_keys (keys) then
						index.remove_keys (keys)
					end
				end
				publish(Void)
			end
		end -- remove_item

	i_th (i: INTEGER): T is
			-- i_th element in the set
		local
			keys: DB_KEYS
			timer: SIMPLE_TIMER
		do
			debug ("man")
				!!timer
				timer.start
			end
			Result := contents.i_th (i)
			!!keys.make_from_array (extract_keys (Result))
			if not index.has_keys (keys) then
				index.add_with_keys (Result, keys)
			end
			debug ("man")
				timer.stop
				io.putstring ("MAN(")
				io.putstring (root_name)
				io.putstring(").i_th :")
				timer.print_time
			end
		end -- i_th

	remove_all is
			-- From RLIST.
		do
			if delete_allowed then
				contents.remove_all
				-- memory_table.clear_all
				index.clear_all
				publish(Void)
			end
		end -- remove_all

feature {NONE}

	set_spec_from_root_info (ri : ROOT_INFO) is
		local
			class_names, one_name : STRING
			pos, slash : INTEGER
		do
			ms_set_spec_from_root_info (ri);
			create_in_memory_index
			if root_info.root_restricted_classes /= Void then
				class_names := root_info.root_restricted_classes
				from
					pos := 1;
					slash := 1;
				until
					slash > class_names.count
				loop
					slash := class_names.index_of ('/', pos);
					if slash = 0 then
						slash := class_names.count + 1
					end
					one_name := class_names.substring(pos, slash - 1)
					one_name.to_upper;
					db_interface.restricted_managers.put (Current, one_name)
					pos := slash + 1
				end -- loop 
			end
		end

	create_in_memory_index is
		do
			!MAN_INDEX[T]!index.make (Current)
		end

feature {PERSISTENT_ROOTS}
 
	flush is
		do
			if not memory_items.empty then
				memory_items.clear_all
			end
			index.clear_all
			preloaded := False
		end

end -- class MAN


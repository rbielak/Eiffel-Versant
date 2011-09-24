-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "Index for items in a MAN"


class MAN_INDEX [T -> MANAGEABLE]

inherit

	MAN_INDEX_SPEC [T]

	DB_GLOBAL_INFO

creation
	
	make

feature


	has_keys (keys: DB_KEYS): BOOLEAN is
		do
			Result := index.has (keys)
		end

	add (item: T) is
		local
			keys: DB_KEYS
		do
			!!keys.make_from_array (man.extract_keys (item))
			index.put (item.pobject_id, keys)
		end

	has (item: T): BOOLEAN is
		local
			keys: DB_KEYS
		do
			!!keys.make_from_array (man.extract_keys (item))
			Result := has_keys (keys)
		end

	remove_keys (keys: DB_KEYS) is
		do
			index.remove (keys)
		end


	add_with_keys (item: T; keys: DB_KEYS) is
		do
			index.put (item.pobject_id, keys)
		end

	add_by_id (object_id: INTEGER; key_attribute_names: ARRAY [STRING]) is
		local
			keys: DB_KEYS
		do
			-- extract values for the key
			extractor.attribute_values (object_id, key_attribute_names)
			-- make key and add to index
			!!keys.make_from_array (extractor.last_tuple)
			index.put (object_id, keys)
		end

	item_by_key (keys: DB_KEYS): T is
		local
			object_id: INTEGER
		do
			object_id := index.item (keys)
			if object_id /= 0 then
				Result := object_from_object_id (object_id)
			end
		end

	preload is
			-- preload the index
		local
			list: PLIST [T]
			i: INTEGER
		do
			list := man.contents
			from i := 1
			until i > list.count
			loop
				add (list.i_th (i))
				i := i + 1
			end
		end
	

feature {NONE} -- implementation

	index: HASH_TABLE [INTEGER, DB_KEYS]
			-- index of object ID's of items

	make (new_man: MAN [T]) is
		require
			valid_man: new_man /= Void
		local
			list: PLIST [T]
			i: INTEGER
		do
			man := new_man
			-- create the index
			!!index.make (100)
			-- add any items that are already in memory
			list := man.contents
			from i := 1
			until i > list.count
			loop
				if db_interface.object_table.item (list.i_th_object_id (i)) /= Void then
					add (object_from_object_id (list.i_th_object_id (i)))
				end
				i := i + 1
			end
		end

	man: MAN [T]
			-- man to which this index belongs

invariant

	man_there: man /= Void

end

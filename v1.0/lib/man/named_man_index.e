-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class NAMED_MAN_INDEX [T -> NAMED_MANAGEABLE]

inherit

	MAN_INDEX_SPEC [T]

creation

	make

feature -- from MAN_INDEX, but redefined

	add (item: T) is
		do
			index.put (item.pobject_id, item.name)
		end

	has_keys (keys: DB_KEYS): BOOLEAN is
		local
			name: STRING
		do
			name ?= keys @ 1
			Result := index.has (name)
		end

	has (item: T): BOOLEAN is
		do
			Result := index.has (item.name)
		end

	remove_keys (keys: DB_KEYS) is
		local
			name: STRING
		do
			name ?= keys @ 1
			index.remove (name)
		end

	add_with_keys (item: T; keys: DB_KEYS) is
		local
			name: STRING
		do
			name ?= keys @ 1
			index.put (item.pobject_id, name)
		end

	item_by_key (keys: DB_KEYS): T is
		local
			object_id: INTEGER
			name: STRING
		do
			name ?= keys @ 1
			object_id := index.item (name)
			if object_id /= 0 then
				Result := object_from_object_id (object_id)
			end
		end

	add_by_id (object_id: INTEGER; key_attribute_names: ARRAY [STRING]) is
		local
			name: STRING
		do
			-- extract values for the key
			extractor.attribute_values (object_id, key_attribute_names)
			name ?= extractor.last_tuple @ 1
			index.put (object_id, name)
		end

	preload is
			-- preload the index
		local
			list: PLIST [T]
			i: INTEGER
			attr: ARRAY [STRING]
		do
			attr := <<"name">>
			list := man.contents
			from i := 1
			until i > list.count
			loop
				add_by_id (list.i_th_object_id (i), attr)
				i := i + 1
			end
		end

feature -- named_man_index specific features

	has_name (item_name: STRING): BOOLEAN is
		require
			item_name /= Void
		do
			Result := index.has (item_name)
		end
	
	item_by_name (item_name: STRING): T is
		require
			item_name /= Void
		local
			object_id: INTEGER
		do
			object_id := index.item (item_name)
			if object_id /= 0 then
				Result := object_from_object_id (object_id)
			end
		end

	remove_by_name (item_name: STRING) is
		do
			index.remove (item_name)
		end

feature {NONE}

	index: HASH_TABLE [INTEGER, STRING]

	make (new_man: like man) is
		local
			i: INTEGER
			list: PLIST [T]
		do
			man := new_man
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

	man: NAMED_MAN [T]

end

-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing
	
	description: "Spec for an in-memory index of a MAN"

deferred class MAN_INDEX_SPEC [T -> MANAGEABLE]

inherit

	DB_GLOBAL_INFO

feature -- deferred, must be specified in descendants

	has_keys (keys: DB_KEYS): BOOLEAN is
		require
			item: keys /= Void
		deferred
		end

	add (item: T) is
		require
			item_valid: (item /= Void) and (item.pobject_id /= 0)
		deferred
		end

	has (item: T): BOOLEAN is
		require
			item_valid: item /= Void
		deferred
		end

	remove_keys (keys: DB_KEYS) is
		require
			keys /= Void
		deferred		
		end


	add_with_keys (item: T; keys: DB_KEYS) is
		require
			item_valid: (item /= Void) and (item.pobject_id /= 0)
			valid_keys: (keys /= Void)
		deferred
		ensure
			item_by_key (keys) = item
		end

	add_by_id (object_id: INTEGER; key_attribute_names: ARRAY [STRING]) is
		require
			object_id_valid: object_id /= 0
			names_valid: key_attribute_names /= Void
		deferred
		end

	item_by_key (keys: DB_KEYS): T is
		require
			keys /= Void
		deferred
		end

	preload is
			-- preload the index
		deferred
		end
	

feature -- implemented for all

	clear_all is
			-- delete al entries from the index
		do
			index.clear_all
		end

	count: INTEGER is
			-- number of entries in the index
		do
			Result := index.count
		end
	

feature {NONE} -- stuff useful for all decendants


	index: HASH_TABLE [INTEGER, HASHABLE] is
			-- index contains object IDs and key could be whatever 
			-- the descendant wants
		deferred
		end


	object_from_object_id (object_id: INTEGER): T is
		require
			valid_object_id: object_id /= 0
		local
			object: POBJECT
			a_cell: CELL [POBJECT]
		do
			-- see if it's in memory
			object := db_interface.object_table.item (object_id)
			if object = Void then
				-- nope, let's retrieve it
				object := db_interface.rebuild_eiffel_object (object_id)
			end
			if cell = Void then
				!!cell.put (Void)
			else
				cell.put (Void)
			end
			a_cell := cell
			a_cell.put (object)
			Result := cell.item
		end

	cell: CELL [T] 

	extractor: ATTRIBUTE_FINDER is
		once
			!!Result
		end

invariant

	index_exists: index /= Void

end

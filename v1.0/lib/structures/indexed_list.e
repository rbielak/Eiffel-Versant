-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- A list indexed by unique keys
--

class INDEXED_LIST [T, S->HASHABLE]
	
inherit
	
	LINKED_LIST [T]
		rename
			make as list_make
		export 
			{NONE} all
			{ANY} start, off, item, forth, back, i_th, count,
					after, finish, before
		end;
	
creation
	
	make

feature
	
	make (index_size : INTEGER) is
		require
			index_positive: index_size > 0
		do
			list_make;
			!!list_index.make (index_size);
		end;
	
	put_key (it :T; key :S) is
		require
			arguments_not_void: (it /= Void) and (key /= Void)
			key_unique: not has_key (key);
		do
			extend (it);
			list_index.put (it, key);
		ensure
			key_there: has_key (key);
		end
	
	has_key (key : S) : BOOLEAN is
		require
			key_valid: key /= Void
		do
			Result := list_index.has (key);
		end;
	
	item_by_key (key : S) : T is
		require
			key_valid: key /= Void
		do
			Result := list_index.item (key);
		ensure
			result_valid: has_key(key) implies (Result /= Void)
		end
	
	remove_by_key (key : S) is
		require
			key_valid: key /= Void;
			key_there: has_key(key)
		local
			litem : T;
			saved_position : CURSOR
		do
			litem := list_index.item (key);
			list_index.remove (key);
			saved_position := cursor;
			start;
			prune (litem);
			if valid_cursor (saved_position) then
				go_to (saved_position)
			end
		ensure
			not_there: not has_key (key)
		end
	
	clear_all is
		do
			wipe_out;
			list_index.clear_all
		ensure
			empty: empty and list_index.empty
		end
	
feature {NONE}
	
	
	list_index : HASH_TABLE [T,S]
			-- index into the list


invariant
	
	consistent: list_index.count = count

end -- INDEXED_LIST

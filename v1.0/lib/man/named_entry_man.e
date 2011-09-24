-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class NAMED_ENTRY_MAN

inherit

	NAMED_MAN [NAMED_ENTRY]
		export 
			{NONE} get_item, extend, has_item
		end

feature

	put (key: STRING; object: POBJECT) is
			-- add a key and an object, no duplicates allowed
		require
			valid_key: key /= Void
			valid_object: (object /= Void)
		local
			ne: NAMED_ENTRY
		do
			!!ne.make (key, object)
			extend (ne)
		ensure
			inserted: has_key (key)	
		end

	item (key: STRING): POBJECT is
		require
			valid_key: key /= Void
		local
			ne: NAMED_ENTRY
		do
			ne := get_item (key)
			if ne /= Void then
				Result := ne.entry
			end
		end

	remove (key: STRING) is
		require
			valid_key: key /= Void
		local
			ne: NAMED_ENTRY
		do
			ne := get_item (key)
			if ne /= Void then
				remove_item (ne)
			end
		end

	has_key (key: STRING): BOOLEAN is
		require
			valid_key: key /= Void
		do
			Result := has_item (key)
		end
	
end

-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class EDITABLE [G]

inherit

	PUBLISHER

feature

	pobject_root_id_of_list: INTEGER is
		do
		end

--	database_of_list: DATABASE is
--		do
--		end

	extend (new: G) is
			-- Add `item' in the list.
		require
			v_is_valid: is_valid_element (new)
		deferred
		end

	is_valid_element (v: G): BOOLEAN is
			-- To be redefined in heirs where we want some
			-- restrictions on the item being inserted in the list.
		do
			Result := True
		end

	remove_item (item: G) is
			-- Remove `item' from the list.
		deferred
		end

	remove_all is
			-- Wipe out the list.
		deferred
		end

end

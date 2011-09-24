-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class SORTABLE_LIST [T]

feature

	count: INTEGER is
			-- Number of items.
		deferred
		end

	position: INTEGER is
			-- Current position in the list.
		deferred
		end

	i_th (i: INTEGER): T is
			-- Item at `i'-th position
		require
			valid_index: i > 0 and i <= count
		deferred
		end

	item: T is
			-- Current item
		require
			valid_position: position > 0 and position <= count
		deferred
		end

	swap (other: INTEGER) is
			-- Exchange item at `other' position with item
			-- at current position.
		require
			valid_position: position > 0 and position <= count
			valid_index: other > 0 and other <= count
		deferred
		end

	start is
			-- Move cursor to first position.
		deferred
		end

	forth is
			-- Move cursor one position to the right.
		require
			valid_move: position <= count
		deferred
		end

	put_i_th (v: like item; i: INTEGER) is
			-- Replace `v' at `i'-th position.
		require
			valid_index: i > 0 and i <= count
			v_is_valid: is_valid_element (v)
		deferred
		end

	is_valid_element (v: T): BOOLEAN is
			-- To be redefined in heirs where we want some
			-- restrictions on the item being inserted in the list.
		do
			Result := True
		end

end

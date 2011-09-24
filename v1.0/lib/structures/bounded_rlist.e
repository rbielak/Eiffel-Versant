-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class BOUNDED_RLIST [G]

inherit

	ARRAYED_LIST [G]
		rename
			extend as arrayed_list_extend,
			wipe_out as arrayed_list_wipe_out,
			make_from_array as arrayed_list_make_from_array
		end

	ARRAYED_LIST [G]
		redefine
			extend, wipe_out, make_from_array
		select
			extend, wipe_out, make_from_array
		end

	RLIST [G]
		undefine
			out, copy, is_equal, has, setup, is_valid_element
		end

	SORTABLE_LIST [G]
		rename
			position as index
		undefine
			out, copy, is_equal, setup
		end

creation

	make, make_from_array

feature

	extend (new: G) is
		do
			arrayed_list_extend (new)
			publish (void)
		end

	remove_item (it: G)  is
		do
			start
			search (it)
			if not after then
				remove
			end
			publish (void)
		end

	remove_all is
		do
			arrayed_list_wipe_out
			publish (void)
		end

	wipe_out is
		do
			remove_all
		end

	make_from_array (a: ARRAY [G]) is
		do
			arrayed_list_make_from_array (a)
			count := a.count
		end

	to_fast_rlist: FAST_RLIST [G] is
		do
			!!Result.make_and_copy (Current)
		end

end -- class BOUNDED_RLIST

-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class FAST_RLIST [G]

inherit

	FAST_LIST [G]
		rename
			wipe_out as fast_list_wipe_out,
			extend as fast_list_extend
		end

	FAST_LIST [G]
		redefine
			extend, wipe_out
		select
			extend, wipe_out
		end

	RLIST [G]
		undefine
			out, copy, is_equal, has,
			to_array, generator, is_valid_element
		end

creation

	make, make_from_array, make_from_fast_list, make_and_copy

feature

	make_from_fast_list (other: FAST_LIST [G]) is
			-- Make Current share all information form `other'.
		do
			accesses := other.accesses
			active := other.active
			count := other.count
			first_element := other.first_element
			object_comparison := other.object_comparison
			position := other.position
		end

	make_and_copy (other: RLIST [G]) is
		require
			other_not_void: other /= Void
		local
			i, other_count: INTEGER
		do
			make
			from
				i := 1
				other_count := other.count
			until
				i > other_count
			loop
				extend (other.i_th (i))
				i := i + 1
			end
		end

	extend (new: G) is
		do
			fast_list_extend (new)
			publish (void)
		end

	remove_item (it: G) is
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
			fast_list_wipe_out
			publish (void)
		end

	wipe_out is
		do
			remove_all
		end

end -- class FAST_RLIST

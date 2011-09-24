-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class FAST_LIST [T]

inherit

	SORTABLE_LIST [T]
		rename
			generator as sortable_list_generator
		end
 
	SORTABLE_LIST [T]
		redefine
			generator
		select
			generator
		end

creation

	make, make_from_array

feature

	first_element: FL_LINKABLE [T]

	active: like first_element

	count: INTEGER

	position: INTEGER

feature {NONE, FAST_RLIST}

	accesses: ARRAY [like first_element]

	accesses_size_increment: INTEGER is 20

	entries_per_slot: INTEGER is 5

feature

	generator: STRING is
		do
			Result := sortable_list_generator.twin
			Result.append ("[ANY]")
		end

	make is
			-- Create an empty list.
		do
			first_element := Void
			active := Void
			count := 0
			position := 0
			!!accesses.make (1, accesses_size_increment)
		end

	make_from_array (other_array: ARRAY [T]) is
			-- Create a list from `other_array'.
		do
			make
			extend_from_array (other_array)
		end

	extend_from_array (other_array: ARRAY [T]) is
			-- Extend current list with `other_array'.
		local
			i, other_upper: INTEGER
		do
			from
				i := other_array.lower
				other_upper := other_array.upper
			until
				i > other_upper
			loop
				extend (other_array.item (i))
				i := i + 1
			end
		end

feature
		-- Conversion

	to_array: ARRAY [T] is
		local
			i: INTEGER
			save_pos: INTEGER
			save_active: like first_element
		do
			save_pos := position
			save_active := active
			!!Result.make (1, count)
			from
				i := 1
				start
			until
				i > count
			loop
				Result.put (item, i)
				forth
				i := i+1
			end
			position := save_pos
			active := save_active
		end

feature
		-- Existence

	empty: BOOLEAN is
			-- Is list empty?
		do
			Result := count = 0
		end

	object_comparison: BOOLEAN

	compare_objects is
			-- Ensure that future search operations will use `equal'
			-- rather than `=' for comparing references.
		do
			object_comparison := True
		end

	compare_references is
			-- Ensure that future search operations will use  `='
			-- rather than `equal' for comparing references.
		do
			object_comparison := False
		end

	search (v: T) is 
			-- Move to first position (at or after current
			-- position) where `item' and `v' are equal.
			-- If structure does not include `v' ensure that
			-- `after' will be true.
			-- (Reference or object equality,
			-- based on `object_comparison'.)
		do
			if object_comparison then
				if v = Void then
					finish
					forth
				else
					from
					until
						after or else (item /= Void and then v.is_equal (item))
					loop
						forth
					end
				end
			else
				if position = 0 then
					forth
				end
				from
				until
					after or else v = item
				loop
					forth
				end
			end
		end

	has (v: T): BOOLEAN is 
			-- Does Current include `v' ?
			-- (Reference or object equality,
			-- based on `object_comparison'.)
		local
			save_pos: like position
			save_active: like active
		do
			save_pos := position
			save_active := active
			start
			search (v)
			Result := not after
			position := save_pos
			active := save_active
		end

	index_of (v: T): INTEGER is
			-- Index of first occurrence of item identical to `v'.
			-- (Reference or object equality,
			-- based on `object_comparison'.) 
			-- 0 if none
		local
			save_pos: like position
			save_active: like active
		do
			save_pos := position
			save_active := active
			start
			search (v)
			if position <= count then
				Result := position
			else
				Result := 0
			end
			position := save_pos
			active := save_active
		end

feature
		-- Adding, updating element(s).

	append (s: FAST_LIST [T]) is
			-- Append a copy of list `s'.
		require
			argument_not_void: s /= Void
			argument_not_current: s /= Current
		do
			from
				s.start
			until
				s.after
			loop
				extend (s.item)
				s.forth
			end
		end

	extend (v: T) is
			-- Add `v' to end.
			-- Do not move cursor.
		require
			v_is_valid: is_valid_element (v)
		local
			p: like first_element
		do
			p := new_cell (v)
			if count = 0 then
				first_element := p
				active := p
				position := 1
			else
				p.put_left (i_th_element (count))
				if position > count then
					active := p
				end
			end
			count := count + 1
			insert_last_element (p)
		end

	put, replace (v: T) is
			-- Replace current item by `v'.
		require
			valid_position: position > 0 and position <= count
			v_is_valid: is_valid_element (v)
		do
			active.put (v)
		end

	put_i_th (v: like item; i: INTEGER) is
			-- Replace `v' at `i'-th position.
		local
			save_pos: like position
			save_active: like active
		do
			save_pos := position
			save_active := active
			go_i_th (i)
			put (v)
			position := save_pos
			active := save_active
		end

	insert_i_th (v: like item; i: INTEGER) is
			-- Insert `v' at `i'-th position.
			-- Move following items to the right
		require
			valid_index: i > 0 and i <= count + 1
			v_is_valid: is_valid_element (v)
		local
			p: like first_element
			save_pos: like position
			save_active: like active
		do
			save_pos := position
			save_active := active
			p := new_cell (v)
			if i < save_pos then
				save_pos := save_pos + 1
			elseif i = save_pos then
				save_active := p
			end

			if i = 1 then
				p.put_right (first_element)
				first_element := p
			elseif i = count + 1 then
				p.put_left (i_th_element (count))
			else
				go_i_th (i)
				p.put_left (active.left)
				p.put_right (active)
			end
			count := count + 1
			if i = count then
				insert_last_element (p)
			else
				insert_i_th_element (i)
			end

			position := save_pos
			active := save_active
		end

	swap (i: INTEGER) is
			-- Exchange item at `i'-th position with item
			-- at current position.
		local
			save_active: like active
			save_item: like item
		do
			if i /= position then
				save_active := active
				active := i_th_element (i)
				save_item := active.item
				active.put (save_active.item)
				save_active.put (save_item)
				active := save_active
			end
		end

feature
		-- Removing element(s)

	remove is
			-- Remove current item.
			-- Move cursor to right neighbor
			-- (or `after' if no right neighbor).
		require
			valid_position: position > 0 and position <= count
		local
			to_be_removed: like first_element
		do
			remove_i_th_element (position)
			if position = 1 then
				active := active.right
				first_element.forget_right
				first_element := active
			elseif position = count then
				to_be_removed := active
				active := Void
				to_be_removed.forget_left
			else
				to_be_removed := active
				active := active.right
				to_be_removed.left.put_right (active)
			end
			count := count - 1
		end

	remove_first is
			-- Remove first element.
			-- If position = 1 then move to right neighbor
			-- (or after if no right neighbor).
			-- Otherwise do not move the cursor but position is
			-- adjusted.
		require
			first_exists: count > 0
		local
			to_be_removed: like first_element
		do
			if position = 1 then
				remove
			else
				remove_i_th_element (1)
				count := count - 1
				to_be_removed := first_element
				first_element := first_element.right
				to_be_removed.forget_right
				position := position - 1
			end
		end

	wipe_out is
			-- Remove all items.
		do
			first_element := Void
			active := Void
			count := 0
			position := 0
			accesses.clear_all
		end

	remove_double_entries is
		local
			winner_position: INTEGER
			winner: like item
		do
			from
				start
			until
				after
			loop
				winner_position := position
				winner := item
				-- Remove following elements same as `item':
				from
					forth
				until
					after
				loop
					if item = winner then
						remove
					else
						forth
					end
				end
				go_i_th (winner_position)
				forth
			end
		end

	remove_equal_entries is
		local
			winner_position: INTEGER
			winner: like item
		do
			from
				start
			until
				after
			loop
				winner_position := position
				winner := item
				-- Remove following elements equal to `item':
				from
					forth
				until
					after
				loop
					if item.is_equal (winner) then
						remove
					else
						forth
					end
				end
				go_i_th (winner_position)
				forth
			end
		end

feature
		-- Access

	i_th (i: INTEGER): T is
			-- Item at `i'-th position
		do
			Result := i_th_element (i).item
		end

	go_i_th (i: INTEGER) is
			-- Move cursor to `i'-th position.
		do
			if i /= position then
				if i <= 0 then
					active := Void
					position := 0
				elseif i > count then
					active := Void
					position := count + 1 
				else
					active := i_th_element (i)
					position := i
				end
			end
		end

	first: T is
			-- Item at first position
		require
			not_empty: count > 0
		do
			Result := first_element.item
		end

	last: T is
			-- Item at last position
		require
			not_empty: count > 0
		do
			Result := i_th_element (count).item
		end

	item: T is
			-- Current item
		do
			Result := active.item
		end

feature
		-- Moving cursor

	start is
			-- Move cursor to first position.
		do
			active := first_element
			position := 1
		end

	finish is
			-- Move cursor to last position.
			-- (Go before if empty)
		do
			if not empty then
				active := i_th_element (count)
			else
				active := Void
			end
			position := count
		end

	forth is
			-- Move cursor one position to the right.
		do
			if position = 0 then
				active := first_element
			else
				active := active.right
			end
			position := position + 1
		end

	back is
			-- Move to previous item.
		do
			if position > 0 then
				if position = count + 1 then
					active := i_th_element (count)
				else
					active := active.left
				end
				position := position - 1
			end
		end

feature
		-- Limits

	off: BOOLEAN is
			-- Is the position off limits ?
		do
			Result := after or before
		end

	after: BOOLEAN is
		do
			Result := position = count + 1
		end

	before: BOOLEAN is
		do
			Result := position = 0
		end

feature {NONE}
		-- Implementation

	new_cell (v: T): like first_element is
		do
			!!Result
			Result.put (v)
		end

	i_th_element (i: INTEGER): like first_element is
		local
			slot: INTEGER
			iters: INTEGER
		do
			slot := ((i-1) // entries_per_slot) + 1
			iters := (i-1) \\ entries_per_slot
			from
				Result := accesses @ slot
			until
				iters = 0
			loop
				Result := Result.right
				iters := iters - 1 
			end
		end

	remove_i_th_element (i: INTEGER) is
		local
			slot: INTEGER
			j, iters: INTEGER
		do
			slot := ((i-1) // entries_per_slot) + 1
			iters := (i-1) \\ entries_per_slot
			if iters = 0 then
				if accesses.item (slot) /= Void then
					accesses.put (accesses.item (slot).right, slot)
				end
			end
			from
				j := slot + 1
			until
				j > accesses.count or else accesses.item (j) = Void
			loop
				accesses.put (accesses.item (j).right, j)
				j := j + 1
			end
		end

	insert_last_element (element: like first_element) is
		local
			slot: INTEGER
			iters: INTEGER
		do
			slot := ((count-1) // entries_per_slot) + 1
			iters := (count-1) \\ entries_per_slot
			if slot > accesses.count then
				accesses.resize (1, accesses.count + accesses_size_increment)
			end
			if iters = 0 then
				accesses.put (element, slot)
			end
		end

	insert_i_th_element (i: INTEGER) is
		local
			needed_slots, slot: INTEGER
			j, iters: INTEGER
			cur_elem: like first_element
		do
			needed_slots := ((count-1) // entries_per_slot) + 1
			if needed_slots > accesses.count then
				accesses.resize (1, accesses.count + accesses_size_increment)
			end

			slot := ((i-1) // entries_per_slot) + 1
			iters := (i-1) \\ entries_per_slot
			if iters = 0 then
				if slot > 1 then
					accesses.put (accesses.item (slot).left, slot)
				else
					accesses.put (first_element, 1)
				end
			end
			from
				j := slot + 1
			until
				j > accesses.count or else accesses.item (j) = Void
			loop
				accesses.put (accesses.item (j).left, j)
				j := j + 1
			end

			if needed_slots > slot and ((count-1) \\ entries_per_slot) = 0 then
				from
					j := entries_per_slot - 1
					cur_elem := accesses.item (needed_slots - 1)
				until
					j = 0
				loop
					cur_elem := cur_elem.right
					j := j - 1
				end
				accesses.put (cur_elem.right, needed_slots)
			end
		end

end -- class FAST_LIST

-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class PARRAY_DOUBLE

inherit

	ARRAY [DOUBLE]
		undefine
			copy
		end

	POBJECT
		undefine
			setup, consistent, copy, is_equal
		redefine
			store_obj, retrieve_obj, store_shallow_obj,
			check_diff_obj, refresh_obj, copy, dispose
		end

	VSTR
		rename
			area as db_area,
			make as vstr_make
--			copy as vstr_copy
		undefine
			setup, consistent, generator, is_equal, dispose, copy
		end

creation

	make, make_from_array

feature

	copy (other: like Current) is
		do
			dispose_area
			pobject_copy (other)
			set_area (standard_clone (other.area))
			db_area := default_pointer
		end

	store_obj , store_shallow_obj (context: DB_OPERATION_CONTEXT) is
			-- For a parray_double a store and a store_shallow are
			-- the same.
		local
			i: INTEGER
			one_double: DOUBLE
		do
			if allowed_to_store and not db_operation_in_progress then
				dispose_area
				-- Now create a vstr of all array
				-- entries and store it
				from
					i := lower
				until
					i > upper
				loop
					one_double := item (i)
					db_area := c_build_double_vstr (db_area, one_double)
					i := i + 1
				end
				pobject_store_obj (context)
			end
		end

	retrieve_obj is
		local
			i: INTEGER
			one_double: DOUBLE
		do
			dispose_area
			pobject_retrieve_obj
			if area = Void then
				make (lower,upper)
			end
			-- Now retrieve the elements of the array
			from
				i := lower
			until
				i > upper
			loop
				one_double := c_get_double_entry (db_area, i - 1)
				put (one_double, i)
				i := i + 1
			end
		end

	refresh_obj (context: DB_OPERATION_CONTEXT) is
		local
			i: INTEGER
			one_double: DOUBLE
		do
			if not db_operation_in_progress then
				dispose_area
				pobject_refresh_obj (context)
				make (lower,upper)
				-- now retrieve the elements of the array
				from
					i := lower
				until
					i > upper
				loop
					one_double := c_get_double_entry (db_area, i - 1)
					put (one_double, i)
					i := i + 1
				end
			end
		end

	check_diff_obj (make_new_persistent: BOOLEAN;
					context: DB_OPERATION_CONTEXT) is
		local
			one_double: DOUBLE
			i, lcount: INTEGER
			is_different: BOOLEAN
		do
			if not db_operation_in_progress then
				-- Check basic attributes first
				pobject_check_diff_obj (make_new_persistent, context)
				-- If we are not on top of the difference stack,
				-- then look at the elements
				if context.diff_stack.empty or else
						context.diff_stack.item /= Current then
					-- Check to see if every entry
					-- in the array is equal to stored one
					lcount := double_count
					-- Sizes match, so have to look at the entries
					if lcount = (upper - lower + 1) then
						from
							i := lower
						until
							(i > upper) or is_different
						loop
							one_double := c_get_double_entry (db_area, i - 1)
							is_different := one_double /= item (i)
							i := i + 1
						end
					else
						is_different := True
					end
					if is_different then
						context.diff_stack.put (Current)
					end
				end
			end
		end

feature {NONE}

	dispose is
		do
			pobject_dispose
			c_dispose_delete_vstr (db_area)
		end

end -- PARRAY_DOUBLE

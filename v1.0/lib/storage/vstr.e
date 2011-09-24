-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- This class should be the only interface between Versant's vstr and Eiffel
-- pointers in order to avoid forgotten or badly placed "deletevstr" operation.
class VSTR inherit

	VSTR_EXTERNALS
		redefine
			copy
		end

	DB_GLOBAL_INFO
		redefine
			copy
		end

	DB_CONSTANTS
		redefine
			copy
		end

	MEMORY
		redefine
			copy, dispose
		end

creation

	make, make_a_copy, make_empty

creation {GC_UPDATE_TOOL}

	make_a_duplicate

feature

	area: POINTER

feature

	make (larea: POINTER) is
			-- This object is always created with an existing instance
			-- of a Versant/C vstr.
		do
			area := larea
		end

	make_a_copy (other: VSTR) is
		do
			area := c_copyvstr (other.area)
		end
	
	make_empty (size_in_bytes: INTEGER) is
			-- create an empty Vstr filled in with NULL characters
		require
			valid_size: size_in_bytes >= 0
		do
			area := c_new_filled_vstr (size_in_bytes, '%U')
		end

	make_a_duplicate (larea: POINTER) is
			-- Used in cases we don't want the original Vstr
			-- to be disposed (We don't "own" it)
		do
			area := c_copyvstr (larea)
		end

feature

	byte_count: INTEGER is
		do
			if area /= default_pointer then
				Result := c_sizeofvstr (area)
			end
		ensure then
			Result >= 0
		end

	integer_count, pointer_count: INTEGER is
		do
			if area /= default_pointer then
				Result := c_sizeofvstr (area) // 4
			end
		ensure then
			Result >= 0
		end

	double_count: INTEGER is
		do
			if area /= default_pointer then
				Result := c_sizeofvstr (area) // 8
			end
		ensure then
			Result >= 0
		end

	exists: BOOLEAN is
		do
			Result := area /= default_pointer
		end

feature
	-- Some access possibilities. No guarantee given here over
	-- the actual resulting type in the Versant's vstr.

	i_th_integer (i: INTEGER): INTEGER is
		require
			index_ok: (i > 0) and (i <= integer_count)
		do
			Result := c_get_entry (area, i - 1)
		end

	i_th_double (i: INTEGER): DOUBLE is
		require
			index_ok: (i > 0) and (i <= double_count)
		do
			Result := c_get_double_entry (area, i - 1)
		end

	i_th_pointer (i: INTEGER): POINTER is
		require
			index_ok: (i > 0) and (i <= pointer_count)
		do
			Result := c_get_ptr_entry (area, i - 1)
		end

feature

	put_i_th_integer (item: INTEGER; index: INTEGER) is
		require
			index_ok: (index > 0) and (index <= integer_count)
		do
			set_ith_int_entry (area, item, index - 1)
		end

	put_i_th_double (item: DOUBLE; index: INTEGER) is
		require
			index_ok: (index > 0) and (index <= double_count)
		do
			set_ith_double_entry (area, item, index - 1)
		end

	put_i_th_pointer (item: POINTER; index: INTEGER) is
		require
			index_ok: (index > 0) and (index <= pointer_count)
		do
			set_ith_ptr_entry (area, item, index - 1)
		end

	insert_i_th_integer (item: INTEGER; index: INTEGER) is
		require
			index_ok: (index > 0) and (index <= integer_count)
		local
			total, i: INTEGER
			old_area: POINTER
		do
			total := integer_count
			old_area := area
			area := default_pointer
			area := o_newvstr ($area, (total + 1) * 4, default_pointer)

			from
				-- 1 to index - 1
				i := 0
			until
				i = index - 1 
			loop
				set_ith_int_entry (area, c_get_entry (old_area, i), i)
				i := i + 1
			end

			-- index
			set_ith_int_entry (area, item, index - 1)

			from
			until
				i = total
			loop
				set_ith_int_entry (area, c_get_entry (old_area, i), i + 1)
				i := i + 1
			end

			if old_area /= default_pointer then
				c_deletevstr (old_area)
			end
		end

	insert_i_th_double (item: DOUBLE; index: INTEGER) is
		require
			index_ok: (index > 0) and (index <= double_count)
		do
			set_ith_double_entry (area, item, index - 1)
		end

	extend_integer (item: INTEGER) is
		do
			area := c_build_int_vstr (area, item)
		end

	extend_double (item: DOUBLE) is
		do
			area := c_build_double_vstr (area, item)
		end

	extend_pointer (item: POINTER) is
		do
			area := c_build_vstr (area, item)
		end

	has_integer (item: INTEGER): BOOLEAN is
		local
			total, i: INTEGER
		do
			from
				total := integer_count - 1
			until
				Result or i > total
			loop
				Result := c_get_entry (area, i) = item
				i := i + 1
			end
		end

	has_double (item: DOUBLE): BOOLEAN is
		local
			total, i: INTEGER
		do
			from
				total := double_count - 1
			until
				Result or i > total
			loop
				Result := c_get_double_entry (area, i) = item
				i := i + 1
			end
		end

	has_pointer (item: POINTER): BOOLEAN is
		local
			total, i: INTEGER
		do
			from
				total := pointer_count - 1
			until
				Result or i > total
			loop
				Result := c_get_ptr_entry (area, i) = item
				i := i + 1
			end
		end

	index_of_integer (item: INTEGER): INTEGER is
		local
			total, i: INTEGER
		do
			from
				total := integer_count
				i := total - 1
			until
				i < 0 or Result > 0
			loop
				if c_get_entry (area, i) = item then
					Result := i + 1
				end
				i := i - 1
			end
		end

	remove_integer (item: INTEGER) is
		local
			tmp_area, diff: POINTER
		do
			tmp_area := c_build_int_vstr (tmp_area, item)
			diff := c_diffvstrobj (area, tmp_area)
			-- delete the old vstrs
			c_deletevstr (area)
			c_deletevstr (tmp_area)
			area := diff
		end

	remove_double (item: DOUBLE) is
		local
			tmp_area, diff: POINTER
		do
			tmp_area := c_build_double_vstr (tmp_area, item)
			diff := c_diffvstrobj (area, tmp_area)
			-- delete the old vstrs
			c_deletevstr (area)
			c_deletevstr (tmp_area)
			area := diff
		end

	remove_pointer (item: POINTER) is
		local
			tmp_area, diff: POINTER
		do
			tmp_area := c_build_vstr (tmp_area, item)
			diff := c_diffvstrobj (area, tmp_area)
			-- delete the old vstrs
			c_deletevstr (area)
			c_deletevstr (tmp_area)
			area := diff
		end

feature

	concat_area (other: VSTR) is
		local
			vstr: POINTER
		do
			if area /= default_pointer then
				vstr := c_concatvstr (area, other.area)
				c_deletevstr (area)
				area := vstr
			else
				area := c_copyvstr (other.area)
			end
		end

	copy_area (other: VSTR) is
			-- Subtle difference with copy, to be reused by heirs.
		do
			if area /= default_pointer then
				c_deletevstr (area)
			end
			area := c_copyvstr (other.area)
		end

	copy, vstr_copy (other: like Current) is
		do
			if area /= default_pointer then
				c_deletevstr (area)
			end
			area := c_copyvstr (other.area)
		end

	integer_is_equal (other: like Current): BOOLEAN is
			-- Compare the actual content of the vstr.
		local
			i, total: INTEGER
			other_area: POINTER
		do
			if integer_count = other.integer_count then
				from
					total := integer_count - 1
					other_area := other.area
					Result := True
				until
					i > total or not Result
				loop
					Result := c_get_entry (area, i) = c_get_entry (other_area, i)
					i := i + 1
				end
			end
		end

	double_is_equal (other: like Current): BOOLEAN is
			-- Compare the actual content of the vstr.
		local
			i, total: INTEGER
			other_area: POINTER
		do
			if double_count = other.double_count then
				from
					total := double_count - 1
					other_area := other.area
					Result := True
				until
					i > total or not Result
				loop
					Result := c_get_double_entry (area, i) =
								c_get_double_entry (other_area, i)
					i := i + 1
				end
			end
		end

feature

	remove_i_th_integer (index: INTEGER) is
		require
			index_valid: (index > 0) and (index <= integer_count)
		local
			last_item: BOOLEAN
		do
			last_item := integer_count = 1 
			c_remove_i_th_int (area, index - 1)
			-- vstr is deleted when the last item is removed
			if last_item then
				area := default_pointer
			end
		ensure
			count_consistent: old integer_count = integer_count + 1
		end

	union_with, vstr_union_with (other: VSTR) is
			-- Perform a union of Current with other,
			-- Result in Current. Elements must be object ID's
		require
			other_not_void: other /= Void
		local
			union_area: POINTER
		do
			if area /= default_pointer then
				union_area := c_unionvstrobj (area, other.area)
				c_deletevstr (area)
				area := union_area
			else
				area := c_copyvstr (other.area)
			end
		end
	
	integer_union_with (other: VSTR) is
			-- Union of elements as integers (except 0)
		require
			other_not_void: (other /= Void) 
		local
			i, int, cnt: INTEGER
		do
			if other.integer_count > 0 then
				from 
					i := 1
					cnt := other.integer_count
				until 
					i > cnt
				loop
					int := other.i_th_integer (i)
					if (int /= 0) and then (not has_integer (int)) then
						extend_integer (int)
					end
					i := i + 1
				end
			end
		end

	intersect_with, vstr_intersect_with (other: VSTR) is
			-- Intersect Current with other,
			-- Result in Current
		require
			other_not_void: other /= Void
		local
			intersect_area: POINTER
		do
			if area /= default_pointer then
				intersect_area := c_intersectvstrobj (area, other.area)
				c_deletevstr (area)
				area := intersect_area
			end
		end
	
	integer_intersect_with (other: VSTR) is
			-- Intersection of elements as integers (except 0)
		require
			other_not_void: (other /= Void) 
		local
			i, int, cnt: INTEGER
			answer: VSTR
		do
			if other.integer_count = 0 then
				dispose_area
			elseif integer_count /= 0 then
				!!answer.make (default_pointer)
				from 
					i := 1
					cnt := other.integer_count
				until
					i > cnt
				loop
					int := other.i_th_integer (i)
					if (int /= 0) and then  has_integer (int) then
						answer.extend_integer (int)
					end
					i := i + 1
				end
				copy_area (answer)
			end
		end

	difference_with, vstr_difference_with (other: VSTR) is
			-- Difference with other
			-- Result in Current
		require
			other_not_void: other /= Void
		local
			diff_area: POINTER
		do
			if area /= default_pointer then
				diff_area := c_diffvstrobj (area, other.area)
				c_deletevstr (area)
				area := diff_area
			else
				area := c_copyvstr (other.area)
			end
		end
	
	
	integer_difference_with (other: VSTR) is
		require
			other_not_void: other /= Void
		local
			i, int, cnt: INTEGER
		do
			if other.integer_count /= 0 then
				from
					i := 1
				until
					-- Note: we want to re-eval this function each time
					-- through the loop, cause the VSTR may shrink
					i > integer_count
				loop
					int := i_th_integer (i)
					if (int /= 0) and then other.has_integer (int) then
						remove_i_th_integer (i)
					else
						i := i + 1
					end
				end
			end
		end

feature

	dispose_area is
		do
			c_dispose_delete_vstr (area)
			area := default_pointer
		end

	dispose is
		do
			c_dispose_delete_vstr (area)
		end
	
feature -- dumping	
	
	
	dump_integer is
		local
			i: INTEGER
		do
			io.putstring ("VSTR[")
			io.putstring (area.out)
			io.putstring ("]=(")
			from i := 1
			until i > integer_count
			loop
				io.putint (i_th_integer (i))
				if i < integer_count then
					io.putstring (", ")
				end
				i := i + 1
			end
			io.putstring (")%N")
		end

end -- class VSTR


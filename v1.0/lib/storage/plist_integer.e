-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class PLIST_INTEGER

inherit

	POBJECT
		redefine
			dispose, copy, is_equal
		end

	RLIST [INTEGER]
		undefine
			has, copy, is_equal
		end

	VSTR
		rename
			make as vstr_make,
			integer_count as count,
			has_integer as has
		undefine
			generator, is_equal, dispose, copy
		end

creation

	make,
	make_from_list,
	make_from_array

feature

	make_from_list (lintegers : FAST_LIST [INTEGER]) is
		require
			valid_call : lintegers /= Void
		do
			make
			from
				lintegers.start
			until
				lintegers.after
			loop
				extend (lintegers.item)
				lintegers.forth
			end
		end

	make_from_array (lintegers : ARRAY [INTEGER]) is
		require
			valid_call : lintegers /= Void
		local
			i, sz : INTEGER
		do
			make
			from
				i := 1
				sz := lintegers.count
			until
				i > sz
			loop
				extend (lintegers.item (i))
				i := i + 1
			end
		end

feature

	copy (other: like Current) is
		do
			dispose_area
			pobject_copy (other)
			area := default_pointer
			vstr_copy (other)
		end

	is_equal (other: like Current): BOOLEAN is
		local
			saved_area: POINTER
			i: INTEGER
		do
			saved_area := area
			area := other.area

			Result := pobject_is_equal (other)
			area := saved_area

			Result := Result and integer_is_equal (other)
		end

	make is
		do
		end

	remove_all is
		do
			dispose_area
			store_area
		end

	append (it: INTEGER) is
		obsolete "Use extend instead. append will be removed soon !"
		do
			extend (it)
		end

	extend (it: INTEGER) is
		require else
			True
		do
			area := c_build_int_vstr (area, it)
			store_area
		ensure then
			count = old count + 1
		end

	remove_item (it: INTEGER) is
		do
			remove_integer (it)
			store_area
		end -- remove_item

	i_th (i: INTEGER): INTEGER is
		do
			Result := c_get_entry (area, i - 1)
		end

	insert_i_th (item: INTEGER; index: INTEGER) is
			-- If index is less that 1 then insert will
			-- happen at the head, if it's more than
			-- "count" then the new element will go at the
			-- tail
		do
			if index > count then
				extend (item)
			else
				-- Here "index <= count"
				-- copy until the new element
				insert_i_th_integer (item, index)
				store_area
				publish (Void)
			end
		end -- insert_i_th


	last : INTEGER is
		do
			if count > 0 then
				Result := i_th (count)
			end
		end

feature {NONE}

	store_area is
		local
			context: DB_OPERATION_CONTEXT
		do
			if pobject_id /= 0 then
				!!context.make_for_store
				db_interface.operation_context_stack.put (context)
				store_obj (context)
				if db_interface.transaction_level = 0 then
					db_interface.commit
				end
				context.mark_objects_not_in_progress
				db_interface.operation_context_stack.put (context)
			end
		end

	dispose is
		do
			pobject_dispose
			c_dispose_delete_vstr (area)
		end

end -- PLIST_INTEGER


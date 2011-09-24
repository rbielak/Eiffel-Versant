-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class PLIST_DOUBLE

inherit

	POBJECT 
		redefine
			dispose, copy, is_equal
		end

	RLIST [DOUBLE]
		undefine
			has, copy, is_equal
		end

	VSTR
		rename
			make as vstr_make,
			double_count as count,
			has_double as has
		undefine
			generator, is_equal, dispose, copy
		end

creation

	make

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
			Result := Result and double_is_equal (other)
		end

	make is
		do
		end

	remove_all is
		do
			dispose_area
			store_area 
		end

	append (it: DOUBLE) is
		obsolete "Use extend instead. append will be removed soon !"
		do
			extend (it)
		end

	extend (it: DOUBLE) is
		require else
			True
		do
			area := c_build_double_vstr (area, it)
			store_area
		ensure then
			count = old count + 1
		end

	remove_item (it: DOUBLE) is
		do
			remove_double (it)
			store_area
		end -- remove_item

	put_i_th (d: DOUBLE; i: INTEGER) is
		do
			put_i_th_double (d, i)
			store_area
		end

	i_th (i: INTEGER): DOUBLE is
		do
			Result := i_th_double (i)
--			Result := c_get_double_entry (area, i - 1)
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
				db_interface.operation_context_stack.remove 
			end
		end

	dispose is
		do
			pobject_dispose
			c_dispose_delete_vstr (area)
		end

end -- PLIST_DOUBLE

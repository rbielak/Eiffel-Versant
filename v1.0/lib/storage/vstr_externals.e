-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class VSTR_EXTERNALS

feature

	c_sizeofvstr (vstr: POINTER): INTEGER is
		external "C"
		end

	c_dump_vstr (v: POINTER) is
		external "C"
		end

feature
	-- Removing values
	
	c_remove_i_th_int (vstr: POINTER; index: INTEGER) is
		external "C"
		end

feature
	-- Getting values

	c_get_entry (vstr: POINTER; index: INTEGER): INTEGER is
		external "C"
		end

	c_get_int_entry (vstr: INTEGER; index: INTEGER): INTEGER is
		external "C"
		alias "c_get_entry"
		end

	c_get_double_entry (vstr: POINTER; index: INTEGER): DOUBLE is
		external "C"
		end

	c_get_bool_entry (vstr: POINTER; index: INTEGER): BOOLEAN is
		external "C"
		end

	c_get_ptr_entry (vstr: POINTER; index: INTEGER): POINTER is
		external "C"
		end

feature
	-- Setting values

	set_ith_entry (vstr: POINTER; item: INTEGER; index: INTEGER) is
		external "C"
		end

	set_ith_int_entry (vstr: POINTER; item: INTEGER; index: INTEGER) is
		external "C"
		alias "set_ith_entry"
		end

	set_ith_double_entry (vstr: POINTER; item: DOUBLE; index: INTEGER) is
		external "C"
		end

	set_ith_bool_entry (vstr: POINTER; item: BOOLEAN; index: INTEGER) is
		external "C"
		end

	set_ith_ptr_entry (vstr: POINTER; item: POINTER; index: INTEGER) is
		external "C"
		end

feature
	-- Building vstrs.

	c_build_vstr (vstrp: POINTER; obj: POINTER): POINTER is
		external "C"
		end

	c_build_int_vstr (vstrp: POINTER; obj: INTEGER): POINTER is
		external "C"
		end

	c_build_double_vstr (vstrp: POINTER; dd: DOUBLE): POINTER is
		external "C"
		end

	c_build_bool_vstr (vstrp: POINTER; bb: BOOLEAN): POINTER is
		external "C"
		end

feature
	-- Set operations

	c_diffvstrobj (v1, v2: POINTER): POINTER is
		external "C"
		end

	c_unionvstrobj (v1, v2: POINTER): POINTER is
		external "C"
		end

	c_intersectvstrobj (v1, v2: POINTER): POINTER is
		external "C"
		end

feature
	-- Appending/Copying

	c_concatvstr (vstr1, vstr2: POINTER): POINTER is
		external "C"
		end

	c_copyvstr (vstr1: POINTER): POINTER is
		external "C"
		end

feature
	-- Creating/Deleting

	o_newvstr (vstrp: POINTER; size: INTEGER; init_data: POINTER): POINTER is
		external "C"
		end
	
	c_new_filled_vstr (size_in_bytes: INTEGER; fill: CHARACTER): POINTER is
		external "C"
		end

	c_deletevstr (vstr: POINTER) is
		external "C"
		end

	c_dispose_delete_vstr (vstr: POINTER) is
		external "C"
		end

end -- VSTR_EXTERNALS

-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class VERSANT_POINTER_EXTERNALS

feature

	set_db_int_o_ptr (ptr: POINTER; off: INTEGER; value: INTEGER) is
		external "C"
		end

	set_db_ptr_o_ptr (ptr: POINTER; off: INTEGER; value: POINTER) is
		external "C"
		end

	set_db_bool_o_ptr (ptr: POINTER; off: INTEGER; value: BOOLEAN) is
		external "C"
		end

	set_db_char_o_ptr (ptr: POINTER; off: INTEGER; value: CHARACTER) is
		external "C"
		end

	set_db_double_o_ptr (ptr: POINTER; off: INTEGER; value: DOUBLE) is
		external "C"
		end

	set_db_string_o_ptr (ptr: POINTER; off: INTEGER; value: POINTER) is
		external "C"
		end

feature

	get_db_int_o_ptr (obj_ptr: POINTER; offset: INTEGER): INTEGER is
		external "C"
		end

	get_db_ptr_o_ptr (obj_ptr: POINTER; offset: INTEGER): POINTER is
		external "C"
		end

	get_db_string_o_ptr (obj_ptr: POINTER; offset: INTEGER): STRING is
		external "C"
		end

	get_db_bool_o_ptr (ptr: POINTER; off: INTEGER): BOOLEAN is
		external "C"
		end

	get_db_char_o_ptr (ptr: POINTER; off: INTEGER): CHARACTER is
		external "C"
		end

	get_db_double_o_ptr (ptr: POINTER; off: INTEGER): DOUBLE is
		external "C"
		end

end

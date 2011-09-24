-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class EIFFEL_EXTERNALS

feature {POBJECT}

	set_nth (k: INTEGER; obj_dest: POINTER; obj_src: POINTER) is
		external "C"
		end -- set_nth

	extract_boolean (offset: INTEGER; object: POINTER): BOOLEAN is
		external "C"
		end -- extract_boolean

	extract_integer (offset: INTEGER; object: POINTER): INTEGER is
		external "C"
		end -- extract_integer

	extract_character (offset: INTEGER; object: POINTER): CHARACTER is
		external "C"
		end -- extract_character

	extract_double (offset: INTEGER; object: POINTER): DOUBLE is
		external "C"
		end -- extract_double

	extract_string (offset: INTEGER; object: POINTER): STRING is
		external "C"
		end -- extract_string

	extract_pointer (offset: INTEGER; object: POINTER): POINTER is
		external "C"
		end -- extract_pointer

	extract_reference (offset: INTEGER; object: POINTER): POBJECT is
		external "C"
		end -- extract_reference

end -- EIFFEL_EXTERNALS

-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class BOOLEAN_PATTRIBUTE

inherit
	
	PATTRIBUTE

creation
	
	make,
	make_new

feature
	
	store_attr, store_shallow_attr (object: POBJECT; obj_ptr: POINTER) is
		local
			value: BOOLEAN
		do
			value := extract_boolean (eiffel_offset, $object)
			set_db_bool_o_ptr (obj_ptr, field_offset, value)
		end
	
	retrieve_attr (object: POBJECT; obj_ptr: POINTER) is
		do
			c_bool_o_retr_ptr (obj_ptr, field_offset, eiffel_offset, object)
		end

	refresh_attr (object: POBJECT; deep: BOOLEAN; obj_ptr: POINTER) is
			-- Refresh the same as retrieve
		do
			retrieve_attr (object, obj_ptr)
		end
	
	is_different (object: POBJECT; obj_ptr: POINTER): BOOLEAN is
		local
			db_value: BOOLEAN
		do
			db_value := get_db_bool_o_ptr (obj_ptr, field_offset)
			Result := db_value /= extract_boolean (eiffel_offset, $object)
			debug ("diff_scanner")
				if Result then
					io.putstring (object.generator)
					io.putstring (":Field differs=")
					io.putstring (name)
					io.new_line
				end
			end
		end

	value_to_string (object_id: INTEGER): STRING is
		local
			c: CHARACTER
		do
			c := get_db_char_o_attr (object_id, field_offset)
			Result := (c /= '%U').out
		end

	value_from_id (object_id: INTEGER): BOOLEAN_REF is
		local
			c: CHARACTER
		do
			c := get_db_char_o_attr (object_id, field_offset)
			Result := (c /= '%U')
		end

	type_is_basic: BOOLEAN is True
	
	eiffel_type: INTEGER is
		do
			Result := Eiffel_boolean
		end

end -- BOOLEAN_PATTRIBUTE

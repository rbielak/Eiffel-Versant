-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class INTEGER_PATTRIBUTE

inherit
	
	PATTRIBUTE 

creation
	
	make,
	make_new

feature
	
	store_attr, store_shallow_attr (object: POBJECT; obj_ptr: POINTER) is
			-- store this attribute in the database
		local
			value: INTEGER
		do
			value := extract_integer (eiffel_offset, $object)
			set_db_int_o_ptr (obj_ptr, field_offset, value)
		end

	retrieve_attr (object: POBJECT; obj_ptr: POINTER) is
		do
			c_int_o_retr_ptr (obj_ptr, field_offset, eiffel_offset, object)
		end

	refresh_attr (object: POBJECT; deep: BOOLEAN; obj_ptr: POINTER) is
			-- Refresh the same as retrieve
		do
			retrieve_attr (object, obj_ptr)
		end

	is_different (object: POBJECT; obj_ptr: POINTER) : BOOLEAN is
		local
			db_value : INTEGER
		do
			db_value := get_db_int_o_ptr (obj_ptr, field_offset)
			Result := db_value /= extract_integer (eiffel_offset, $object)
			debug ("diff_scanner")
				if Result then
					io.putstring (object.generator) 
					io.putstring (":Field differs=")
					io.putstring (name)
					io.new_line
				end
			end
		end

	type_is_basic: BOOLEAN is True
	
	eiffel_type: INTEGER is
		do
			Result := Eiffel_integer
		end

	value_to_string (object_id : INTEGER) : STRING is
		local
			i: INTEGER
		do
			i := get_db_int_o_attr (object_id, field_offset);
			Result := i.out
		end

	value_from_id (object_id : INTEGER) : INTEGER_REF is
		do
			Result := get_db_int_o_attr (object_id, field_offset);
		end

end -- INTEGER_PATTRIBUTE

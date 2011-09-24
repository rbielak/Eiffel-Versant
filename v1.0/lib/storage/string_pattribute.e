-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class STRING_PATTRIBUTE

inherit
	
	PATTRIBUTE

creation
	
	make,
	make_new

feature
	
	store_attr, store_shallow_attr (object: POBJECT; obj_ptr: POINTER) is
		local
			str: STRING
		do
			str := extract_string (eiffel_offset, $object)
			if str = Void then
				-- String is void, requires
				-- special handlings
				set_db_int_o_ptr (obj_ptr, field_offset, 0)
			else
				set_db_string_o_ptr (obj_ptr, field_offset, $(str.to_c))
			end
		end
	
	retrieve_attr (object: POBJECT; obj_ptr: POINTER) is
		local
			str: STRING
		do
			str := get_db_string_o_ptr (obj_ptr, field_offset)
			set_nth (eiffel_offset, $object, $str);
		end

	refresh_attr (object: POBJECT; deep: BOOLEAN; obj_ptr: POINTER) is
			-- Refresh the same as retrieve
		do
			retrieve_attr (object, obj_ptr)
		end

	is_different (object : POBJECT; obj_ptr: POINTER): BOOLEAN is
		local
			str, db_value : STRING
		do
			str := extract_string (eiffel_offset, $object)

			if str = Void then
				Result := c_is_string_different (obj_ptr, field_offset,
												 default_pointer, 0)
			else
				Result := c_is_string_different (obj_ptr, field_offset,
												 $(str.area), str.count)
			end

--			db_value := get_db_string_o_ptr (obj_ptr, field_offset)
--			if str /= Void then
--				Result := (db_value = Void) or else not str.is_equal (db_value)
--			else
--				Result := db_value /= Void
--			end
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
			Result := Eiffel_string
		end

	value_to_string (object_id : INTEGER) : STRING is
		do
			Result := get_db_string_o_attr (object_id, field_offset)
			if Result = void then
				Result := "<void>"
			end
		end

	value_from_id (object_id : INTEGER) : STRING is
		do
			Result := get_db_string_o_attr (object_id, field_offset)
		end

end -- STRING_PATTRIBUTE

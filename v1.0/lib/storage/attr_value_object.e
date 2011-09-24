-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class ATTR_VALUE_OBJECT

inherit
	
	ATTR_VALUE

feature

	extract_db_value (pobject_id : INTEGER; l_attr_name : STRING) : POBJECT is
			-- Extract the actual value of approriate type
			-- from the database
		local
			obj_id: INTEGER
		do
			obj_id := get_db_int_attr (pobject_id, $(l_attr_name.to_c));
			if obj_id /= 0 then
				Result := db_interface.rebuild_eiffel_object (obj_id)
			end
		end;

end -- ATTR_VALUE_OBJECT

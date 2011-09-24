-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class ATTR_VALUE_POINTER

inherit

	ATTR_VALUE

feature

	extract_db_value (pobject_id : INTEGER; l_attr_name : STRING) : POINTER_REF is
			-- Extract the actual value of approriate type
			-- from the database
		do
			Result := get_db_ptr_attr (pobject_id, $(l_attr_name.to_c))
			check_error;
		end;


end -- class ATTR_VALUE_POINTER

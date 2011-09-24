-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class ATTR_VALUE_INTEGER

inherit

	ATTR_VALUE


feature{NONE}
	
	extract_db_value (pobject_id : INTEGER; l_attr_name : STRING) : INTEGER_REF is
			-- Extract the actual value of approriate type
			-- from the database
		do
			Result := get_db_int_attr (pobject_id, $(l_attr_name.to_c))
			check_error;
		end;

end -- ATTR_VALUE_INTEGER

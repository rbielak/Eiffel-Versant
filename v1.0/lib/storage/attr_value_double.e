-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class ATTR_VALUE_DOUBLE

inherit

	ATTR_VALUE

feature
	
	extract_db_value (pobject_id : INTEGER; l_attr_name : STRING) : DOUBLE_REF is
			-- Extract the actual value of approriate type
			-- from the database
		local
			d: DOUBLE
		do
			get_db_double_attr (pobject_id, $(l_attr_name.to_c), $d)
			Result := d
			check_error;
		end;

end -- class ATTR_VALUE_DOUBLE

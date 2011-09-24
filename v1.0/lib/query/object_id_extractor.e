-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class OBJECT_ID_EXTRACTOR

inherit

	ATTR_VALUE
		redefine
			standard_extraction
		end

feature {NONE}

	standard_extraction: BOOLEAN is
		do
			Result := False
		end

	extract_db_value (object_id : INTEGER; attr_name : STRING) : INTEGER_REF is
			-- extract objects ID
		do
			Result := get_db_int_attr (object_id, $(attr_name.to_c))
		end

end
	

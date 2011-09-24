-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class VL_AMOUNT_EXTRACTOR

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

	extract_db_value (object_id: INTEGER; attr_name: STRING): VERY_LIGHT_AMOUNT is
			-- extract an AMOUNT[UNIT] as VERY_LIGHT_AMOUNT
		local
			amt_id: INTEGER
		do
			amt_id := get_db_int_attr (object_id, $(attr_name.to_c))
			if amt_id /= 0 then
				!!Result.make_from_amount_pobject_id (amt_id)
			end
		end;

end

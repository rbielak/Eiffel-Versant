-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Maps Versant schema type to schema definition language type
--

class SCHEMA_TYPE_MAPPER
	
inherit
	
	DB_CONSTANTS

feature
	
	schema_type (attr : PATTRIBUTE) : STRING is
		require
			attr_there: attr /= Void;
		do
			if attr.repetition = 1 then
				inspect attr.Eiffel_type_code
				when Eiffel_string then
					Result := "string"
				when Eiffel_char then
					Result := "char"
				when Eiffel_boolean then
					Result := "boolean"
				when Eiffel_double then
					Result := "double"
				when Eiffel_integer then
					if equal (attr.type, "o_ptr") then
						Result := "o_ptr"
					else
						Result := "integer"
					end
				else
					Result := attr.type
				end; -- inspect
			elseif attr.repetition = -1 then
				if attr.type.is_equal ("char") then
					Result := "string"
				else
					Result := "list (";
					if attr.type.is_equal ("o_4b") then
						Result.append ("integer")
					elseif attr.type.is_equal ("o_double") then
						Result.append ("double")
					elseif attr.type.is_equal ("o_u1b") then
						Result.append ("boolean")
					else
						Result.append (attr.type)
					end;
					Result.append (")");
				end
			end;
		ensure
			Result /= Void
		end;

invariant

end -- SCHEMA_TYPE_MAPPER

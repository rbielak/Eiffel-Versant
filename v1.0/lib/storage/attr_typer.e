-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- This class uses the database schema to find the type of the attribute
-- specified by the attribute path name
--

class ATTR_TYPER

inherit
	DB_GLOBAL_INFO
	DB_CONSTANTS

feature
	
	type_of_attr (class_name : STRING; path : ATTR_PATH) : INTEGER is
		require
			class_name_ok: (class_name /= Void)
			path_ok: path /= Void
		local
			pclass: PCLASS;
			name: STRING;
			attr_desc: PATTRIBUTE;
			i: INTEGER;
		do
			Result := Eiffel_unknown_type
			pclass := db_interface.find_class (
						db_interface.view_table.versant_class (class_name))
			from i := 1
			until i > path.count
			loop
				attr_desc := pclass.attributes.item (path.i_th(i));
				if i = path.count then
					Result := attr_desc.eiffel_type_code;
				else
					inspect attr_desc.eiffel_type_code
					when Eiffel_object then
						pclass := db_interface.find_class (attr_desc.type)
					else
						except.raise ("Invalid type in path")
					end
				end;
				i := i + 1
			end
		ensure
			Result /= Eiffel_unknown_type
		rescue
			io.putstring ("Failed to find type of ")
			io.putstring (class_name)
			io.putstring (".")
			io.putstring (path.path)
			io.new_line
		end

end -- ATTR_TYPE

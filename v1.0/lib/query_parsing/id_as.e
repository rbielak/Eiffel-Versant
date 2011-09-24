-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- Node for id

class ID_AS

inherit
	
	ACCESSIBLE_FEATURE
		undefine
			copy, is_equal, consistent, setup
		end

	STRING
		rename
			make as string_make
		end

creation

	make

feature

	make (s: STRING) is
		require
			string_not_void: s /= Void
		do
			string_make (s.count + 1)
			append (s)
		ensure then
			not_empty: not empty
		end

feature
 
	attribute_name: STRING is
		do
			Result := Current.twin
		end

	is_subscripted: BOOLEAN is False
 
	subscript: INTEGER is -1
 
	is_dynamic_subscript: BOOLEAN is False
 
feature
		-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		do
			bc.bcode.extend (ID_BC)
			bc.bcode.extend (bc.add_string_value (Current.twin))
		end

end -- class ID_AS

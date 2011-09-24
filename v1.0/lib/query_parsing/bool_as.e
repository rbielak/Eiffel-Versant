-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- Node for boolean constant

class BOOL_AS

inherit

	CONSTANT_AS
		redefine 
			is_it_boolean
		end

creation

	make

feature -- Attributes

	value: BOOLEAN
			-- Boolean value

feature -- Initialization

	make (lval: BOOLEAN) is
		do
			value := lval
		end

	out: STRING is
		do
			Result := value.out
		end
	
	is_it_boolean : BOOLEAN is True

feature
		-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		do
			bc.bcode.extend (BOOL_BC)
			bc.bcode.extend (bc.add_bool_value (value))
		end

end

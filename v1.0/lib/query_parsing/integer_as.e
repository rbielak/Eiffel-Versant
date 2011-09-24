-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- Node for integer constant

class INTEGER_AS

inherit

	SUBSCRIPT_ARGUMENT_AS

	CONSTANT_AS
		redefine
			is_it_integer
		end

creation

	make

feature

	value: INTEGER
			-- Integer value

feature -- Initialization

	make (lval: INTEGER) is
		do
			value := lval
		end

	out: STRING is
		do
			Result := value.out
		end

	subscript: INTEGER is
		do
			Result := value
		end
 
	is_dynamic_subscript: BOOLEAN is False

feature -- Conveniences
	
	is_it_integer : BOOLEAN is True

feature
		-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		do
			bc.bcode.extend (INT_BC)
			bc.bcode.extend (value)
		end

end

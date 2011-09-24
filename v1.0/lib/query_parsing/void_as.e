-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- Node for Void constant

class VOID_AS

inherit

	CONSTANT_AS
		redefine
			is_it_void
		end

feature -- Initialization

	out: STRING is
		do
			Result := "void"
		end
	
	is_it_void: BOOLEAN is True

feature
		-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		do
			bc.bcode.extend (VOID_BC)
		end

end

-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- Node for character constant

class CHAR_AS

inherit

	CONSTANT_AS
		redefine
			is_character
		end

creation

	make

feature

	value: CHARACTER
			-- Character value

feature -- Initialization

	make (lval: CHARACTER) is
			-- Yacc initialization
		do
			value := lval
		end

	out: STRING is
		do
			Result := value.out
		end

feature -- Conveniences

	is_character: BOOLEAN is True

feature
		-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		do
			bc.bcode.extend (CHAR_BC)
			bc.bcode.extend (bc.add_char_value (value))
		end

end

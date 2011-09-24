-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- Node for real constant

class REAL_AS

inherit

	CONSTANT_AS

creation

	make

feature

	value: STRING
			-- Real value

feature -- Initilization

	make (lval: like value) is
		do
			value := lval
		end

	minus_str: STRING is "-"

	unary_minus is
		do
			value.prepend (minus_str)
		end

	out: STRING is
		do
			Result := value.twin
		end

feature
		-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		do
			bc.bcode.extend (REAL_BC)
			bc.bcode.extend (bc.add_dbl_value (value.to_double))
		end

end

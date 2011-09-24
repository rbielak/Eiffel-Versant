-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DYNAMIC_ARG_AS

inherit

	FEATURE_AS

	SUBSCRIPT_ARGUMENT_AS

	LIKEABLE_AS

creation

	make

feature -- Attribute

	parameter_number: INTEGER
			-- Take as value this position in the parameters stack.

feature -- Initialization

	make (lparameter_number: INTEGER) is
		do
			parameter_number := lparameter_number
		end

	out: STRING is
		do
			Result := parameter_number.out
			Result.prepend ("$")
		end

	subscript: INTEGER is
		do
			Result := parameter_number
		end
 
	is_dynamic_subscript: BOOLEAN is True

feature
		-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		do
			bc.bcode.extend (DYNAMIC_BC)
			bc.bcode.extend (parameter_number)
		end

end

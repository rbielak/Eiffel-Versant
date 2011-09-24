-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class GE_AS

inherit

	COMPARISON_AS

creation

	make

feature

	operator_name: STRING is ">="

	operator_type: INTEGER is
		do
			Result := db_greater_than_or_eq
		end

feature
		-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		do
			bc.bcode.extend (GE_BC)
			left.build_byte_code (bc)
			right.build_byte_code (bc)
		end

end

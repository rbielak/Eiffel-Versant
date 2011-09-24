-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class BRACKETED_AS

inherit

	ACCESSIBLE_FEATURE

creation

	make

feature -- Attribute
	-- expr1 [expr2]

	expr1: ID_AS

	expr2: SUBSCRIPT_ARGUMENT_AS

feature -- Initialization

	make (lexp1: like expr1; lexp2: like expr2) is
		require
			expr1_not_void:lexp1 /= Void
			expr2_not_void:lexp2 /= Void
		do
			expr1 := lexp1
			expr2 := lexp2
		end

	out: STRING is
		do
			Result := expr1.out
			Result.append ("[")
			Result.append (expr2.out)
			Result.append ("]")
		end

feature
		-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		do
			bc.bcode.extend (BRACKETED_BC)
			expr1.build_byte_code (bc)
			expr2.build_byte_code (bc)
		end

feature

	attribute_name: STRING is
		do
			Result := expr1.twin
		end

	is_subscripted: BOOLEAN is True
 
	subscript: INTEGER is
		do
			Result := expr2.subscript
		end
 
	is_dynamic_subscript: BOOLEAN is
		do
			Result := expr2.is_dynamic_subscript
		end

end

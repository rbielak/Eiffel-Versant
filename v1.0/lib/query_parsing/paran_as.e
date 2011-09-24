-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- Abstract description of a parenthesized expression

class PARAN_AS

inherit

	BOOLEAN_EXPRESSION_AS

creation

	make

feature

	expr: BOOLEAN_EXPRESSION_AS
			-- Parenthesized expression

feature -- Initialization

	make (lexpr: like expr) is
		require
			expr_exists: lexpr /= Void
		do
			expr := lexpr
		end

	out: STRING is
		do
			Result := expr.out
			Result.prepend ("(")
			Result.append (")")
		end

	action (pred_block: DB_QUERY_PREDICATE_BLOCK; pred_desc_list: LIST[PREDICATE_DESC]) is
		do
			expr.action (pred_block, pred_desc_list)
		end

feature
		-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		do
			bc.bcode.extend (PARAN_BC)
			expr.build_byte_code (bc)
		end

end

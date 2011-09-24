-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class NOT_AS

inherit

	BOOLEAN_EXPRESSION_AS

creation

	make

feature

	expr: BOOLEAN_EXPRESSION_AS
			-- Negated Expression

	make (lexpr: like expr) is
		require
			expr_exists: lexpr /= Void
		do
			expr := lexpr
		end

	out: STRING is
		do
			Result := ("not ").twin
			Result.append (expr.out)
		end

feature

	action (pred_block: DB_QUERY_PREDICATE_BLOCK; pred_desc_list : LIST[PREDICATE_DESC]) is
		local
			new_pred_block: DB_QUERY_PREDICATE_BLOCK
		do
			!!new_pred_block.make_as_not
			pred_block.add_predicate_block (new_pred_block)
			expr.action (new_pred_block, pred_desc_list)
		end

feature
		-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		do
			bc.bcode.extend (NOT_BC)
			expr.build_byte_code (bc)
		end

end

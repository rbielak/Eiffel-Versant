-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class OR_AS

inherit

	BOOLEAN_EXPRESSION_AS

	DB_CONSTANTS
		undefine
			out
		end

creation

	make

feature

	left: BOOLEAN_EXPRESSION_AS
			-- Left operand

	right: BOOLEAN_EXPRESSION_AS
			-- Right operand

	make (lleft: like left; lright: like right) is
		require
			left_exists: lleft /= Void
			right_exists: lright /= Void
		do
			left := lleft
			right := lright
		end

	out: STRING is
		do
			Result := left.out
			Result.append (" or ")
			Result.append (right.out)
		end

feature
	-- Buildin the predicates

	action (pred_block: DB_QUERY_PREDICATE_BLOCK; pred_desc_list: LIST[PREDICATE_DESC]) is
		local
			new_pred_block: DB_QUERY_PREDICATE_BLOCK
		do
			if pred_block.operation /= db_o_or then
				!!new_pred_block.make_as_or
				pred_block.add_predicate_block (new_pred_block)
			else
				new_pred_block := pred_block
			end
			left.action (new_pred_block, pred_desc_list);
			right.action (new_pred_block, pred_desc_list);
		end


feature
		-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		local
			count_before, count_left, count_right: INTEGER
		do
			count_before := bc.bcode.count
			bc.bcode.extend (OR_BC)
			bc.bcode.extend (0)
			left.build_byte_code (bc)
			count_left := bc.bcode.count - count_before - 2
			right.build_byte_code (bc)
			count_right := bc.bcode.count - count_before - 2 - count_left
			bc.bcode.put_i_th (count_right, count_before + 2)
		end

end

-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- descriptor of a query predicate
--

class PREDICATE_DESC

inherit
	DB_CONSTANTS

creation
	make

feature

	feature_access: FEATURE_ACCESS

	operation: INTEGER

	is_path_predicate: BOOLEAN is
		do
			Result := feature_access.next /= Void
		end

	argument_to_compare: INTEGER

	set_argument_to_compare (new_argument: INTEGER) is
		do
			argument_to_compare := new_argument
		end

	predicate: DB_QUERY_PREDICATE [ANY]

	set_predicate (new_predicate: DB_QUERY_PREDICATE[ANY]) is
		require
			pred_ok: new_predicate /= Void
		do
			predicate := new_predicate
		end
	
	predicate_block : DB_QUERY_PREDICATE_BLOCK
			-- predicate block to which this predicate
			-- belongs to

	make (new_feat: FEATURE_ACCESS; new_operation: INTEGER; 
	      arg_no: INTEGER; pb: DB_QUERY_PREDICATE_BLOCK) is
		require
			pb_ok: pb /= Void
			feature_ok: new_feat /= Void
		do
			feature_access := new_feat
			operation := new_operation
			argument_to_compare := arg_no
			predicate_block := pb
		end

end -- PREDICATE_DESC

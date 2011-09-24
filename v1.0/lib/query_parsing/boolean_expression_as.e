-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- Abstract class for boolean expression nodes

deferred class BOOLEAN_EXPRESSION_AS

inherit

	SHARED_BYTE_CODE_AS
		undefine
			out
		end
	
feature

	action (pred_block: DB_QUERY_PREDICATE_BLOCK; pred_desc_list: LIST[PREDICATE_DESC]) is
		require
			valid_list: pred_desc_list /= Void
		deferred
		end

end

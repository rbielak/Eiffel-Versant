-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class IN_AS

inherit

	BOOLEAN_EXPRESSION_AS
	
	DB_CONSTANTS
		undefine
			out
		end

creation

	make

feature -- Attribute

	left_expr: VALUE_AS

	in_expr: FEATURE_AS

feature -- Initialization

	make (lleft: like left_expr; lin_expr: like in_expr) is
		require
			left_exists: lleft /= Void
			in_exists: lin_expr /= Void
		do
			left_expr := lleft
			in_expr := lin_expr
		end

	out: STRING is
		do
			Result := left_expr.out
			Result.append (" in ")
			Result.append (in_expr.out)
		end

	action (pred_block: DB_QUERY_PREDICATE_BLOCK; pred_desc_list : LIST [PREDICATE_DESC]) is
			-- Handle expressions like "$1 in attribute_name"
		local
			pred_desc : PREDICATE_DESC
			dynamic_arg : DYNAMIC_ARG_AS
			ex : EXCEPTIONS
			feature_call: FEATURE_CALL_AS
		do
			-- For now only "$1 in id" syntax is handled
			dynamic_arg ?= left_expr;			
			feature_call ?= in_expr;
			if (dynamic_arg = Void) or (feature_call = Void) then
				!!ex;
				ex.raise ("Unsuported IN construct")
			else
				!!pred_desc.make (feature_call.build_feature_access,
						  db_in_list, dynamic_arg.parameter_number,
						  pred_block);
				pred_desc_list.extend (pred_desc);
			end
		end

feature
 
	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		do
			bc.bcode.extend (IN_BC)
			left_expr.build_byte_code (bc)
			in_expr.build_byte_code (bc)
		end

end

-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- The form of this predicate must be of the form
--    attr_name like "string"
--
class LIKE_AS
	
inherit
	
	BOOLEAN_EXPRESSION_AS

	DB_CONSTANTS
		undefine
			out
		end

creation

	make

feature -- Attribute
	-- left_expr like like_expr
	
	left_expr: FEATURE_CALL_AS
	
	like_expr: LIKEABLE_AS
	
feature -- Initialization
	
	make (lleft: like left_expr; llike: like like_expr) is
			-- Yacc initialization
		require
			left_exists: lleft /= Void
			like_exists: llike /= Void
		do
			left_expr := lleft
			like_expr := llike
		end
	
	out: STRING is
		do
			Result := left_expr.out
			Result.append (" like ")
			Result.append (like_expr.out)
		end
	
	action (pred_block: DB_QUERY_PREDICATE_BLOCK; pred_desc_list : LIST [PREDICATE_DESC]) is
		local
			pdesc : PREDICATE_DESC
			predicate : DB_STRING_PREDICATE
			pattern : STRING_AS
			dynamic_arg : DYNAMIC_ARG_AS
			ex : EXCEPTIONS
			feature_access: FEATURE_ACCESS
		do
			feature_access := left_expr.build_feature_access
			!!pdesc.make (feature_access, db_like, 0, pred_block);
			pattern ?= like_expr;
			if pattern = Void then
				dynamic_arg ?= like_expr
				pdesc.set_argument_to_compare (dynamic_arg.parameter_number);
			else
				-- Constant pattern
				!!predicate.make_with_feature_access 
						(feature_access, pattern.value);
				predicate.set_operation (db_like);
				pdesc.set_predicate (predicate);
			end;
			pred_desc_list.extend (pdesc);
		end

feature
		-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		do
			bc.bcode.extend (LIKE_BC)
			left_expr.build_byte_code (bc)
			like_expr.build_byte_code (bc)
		end

end

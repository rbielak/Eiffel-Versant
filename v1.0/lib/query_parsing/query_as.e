-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class QUERY_AS

inherit

	SHARED_BYTE_CODE_AS
		undefine 
			out
		end

creation

	make

feature -- Attributes

	query: BOOLEAN_EXPRESSION_AS
			-- Root node for the query

feature -- Initialization

	make (lquery: like query) is
		require
			query_not_void: lquery /= Void
		do
			query := lquery
		end

	out: STRING is
		do
			Result := query.out
		end

	dump is
		do
			io.putstring (out)
			io.new_line
		end

	action (pred_block: DB_QUERY_PREDICATE_BLOCK; pred_desc_list : LIST[PREDICATE_DESC]) is
		local
			or_expression: OR_AS
		do
			debug ("select_query");
				io.putstring ("QUERY_AS.action...%N");
			end;
			-- Check to see if top expresion if "or", if
			-- so fix up the predicate block
			or_expression ?= query
			if or_expression /= Void then
				pred_block.make_as_or
			end
			query.action (pred_block, pred_desc_list);
		end

feature
		-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		do
			query.build_byte_code (bc)
		end

	interpreter: BYTE_CODE is
		local
			bc: BYTE_CODE_GENERATOR
		do
			!!bc.make
			build_byte_code (bc)
			Result := bc.byte_code
		end

end

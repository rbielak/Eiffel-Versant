-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- Binary comparison operation

deferred class COMPARISON_AS

inherit

	BOOLEAN_EXPRESSION_AS

	DB_CONSTANTS
		undefine
			out
		end

feature

	left: FEATURE_CALL_AS
			-- Left operand

	right: VALUE_AS
			-- Right operand

	make (lleft: like left; lright: like right) is
			-- Yacc initialization
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
			Result.append (" ")
			Result.append (operator_name)
			Result.append (" ")
			Result.append (right.out)
		end

	operator_name: STRING is
		deferred
		end

	operator_type: INTEGER is
		deferred
		end

feature

	action (pred_block: DB_QUERY_PREDICATE_BLOCK; pred_desc_list: LIST[PREDICATE_DESC]) is
		local
			pred_desc: PREDICATE_DESC
			feature_call: FEATURE_CALL_AS
			dynamic_arg: DYNAMIC_ARG_AS
			predicate: DB_QUERY_PREDICATE[ANY]
			feature_access: FEATURE_ACCESS
			parm_number: INTEGER
			const: CONSTANT_AS
			int: INTEGER_AS
			char: CHAR_AS
			bool: BOOL_AS
			string: STRING_AS
			ex: EXCEPTIONS
		do
			debug ("select_query")
				io.putstring ("COMPARISON_AS.action called. %N")
			end

			feature_access := left.build_feature_access

			--
			-- Get parameter number
			--
			dynamic_arg ?= right
			if dynamic_arg /= Void then
				parm_number := dynamic_arg.parameter_number
			else
				-- Must be a constant
				const ?= right
				if const /= Void then
					if const.is_it_void then
						!DB_OBJECT_PREDICATE!predicate.make_with_feature_access (
								feature_access, Void)
					elseif const.is_it_integer then
						int ?= const
						!DB_INTEGER_PREDICATE!predicate.make_with_feature_access (
								feature_access, int.value)
					elseif const.is_it_boolean then
						bool ?= const
						!DB_BOOLEAN_PREDICATE!predicate.make_with_feature_access (
								feature_access, bool.value)
					elseif const.is_character then
						char ?= const
						!DB_CHARACTER_PREDICATE!predicate.make_with_feature_access (
								feature_access, char.value)
					elseif const.is_string then
						string ?= const
						!DB_STRING_PREDICATE!predicate.make_with_feature_access (
								feature_access, string.value)
					else
						!!ex; ex.raise ("Can't handle this type of constant yet")
					end
				else
					!!ex; ex.raise ("Can't handle this right type yet")
				end
			end

			-- Now create the predicate descriptor and
			-- perhaps the predicate
			!!pred_desc.make (feature_access, operator_type, parm_number, pred_block)
			if predicate /= Void then
				pred_desc.set_predicate (predicate)
				predicate.set_operation (operator_type)
			end
			pred_desc_list.extend (pred_desc)
		end

end

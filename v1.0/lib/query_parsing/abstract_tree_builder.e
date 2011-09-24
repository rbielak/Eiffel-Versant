-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- Main class for the parsing of an SQL-like
-- query string which builds an Abstract Syntax
-- Tree.

class ABSTRACT_TREE_BUILDER

feature

	ast_build (q_string: STRING): QUERY_AS is
		do
			syntax_error := false
			column := 1
			current_line := q_string.twin
			-- current_line.to_lower
			smart_to_lower (current_line)
			if current_line.count = 0 then
				cc := end_of_text
			else
				cc := current_line.item (1)
			end
			skip_space
			if a_boolean_expression and then not syntax_error then
				!!Result.make (last_boolean_expression)
			else
				syntax_error := true
			end
		end

	syntax_error: BOOLEAN

feature {NONE}
		-- Parsing utilities


	smart_to_lower (str: STRING) is
			-- change all the characters to lowers case except 
			-- literals
		local
			i: INTEGER
			literal: BOOLEAN
			ch: CHARACTER
		do
			from i := 1
			until i > str.count
			loop
				ch := str.item (i)
				if ch = '"' then
					literal := not literal
				elseif not literal then
					ch := ch.lower
					str.put (ch, i)
				end
				i := i + 1
			end
		end

	end_of_text: CHARACTER is '%/0/'
			-- Flag of the end of the `text'.

	column: INTEGER
	current_line: STRING
	cc: CHARACTER

	end_of_input: BOOLEAN is
		do
			Result := cc = end_of_text
		end

	start_column: INTEGER
		-- To store beginning position of : `a_keyword', `a_integer',
		-- `a_real', `skip1' and `skip2'

	go_back_at (c: INTEGER) is
			-- Go back to `c'.
  		do
			column := c
			if column = current_line.count + 1 then
				cc := end_of_text
			elseif column = 0 then
				cc := '%U'
			else
				cc := current_line.item (column)
			end
		end

	skip_space is
		do
			from
			until
				cc /= ' ' or cc = end_of_text
			loop
				next_char
			end
		end

	next_char is
		do
			if column < current_line.count then
				column := column + 1
				cc := current_line.item (column)
			else
				column := column + 1
				cc := end_of_text
			end
		end

	prev_char is
		do
			if column > 1 then
				column := column - 1
				cc := current_line.item (column)
			else
				column := 0
				cc := '%U'
			end
		end

	skip1 (char: CHARACTER): BOOLEAN is
		do
			if char = cc then
				start_column := column
				Result := true
				next_char
				skip_space
			end
		end

	skip2 (c1, c2: CHARACTER): BOOLEAN is
		do
			if c1 = cc then
				start_column := column
				next_char
				if c2 = cc then
					Result := true
					next_char
					skip_space
				else
					prev_char
				end
			end
		end
	
	a_keyword (keyword: STRING): BOOLEAN is
			-- Look for `keyword' beginning strictly at current position.
			-- A keyword is never followed by a character of
			-- this set : 'A'..'Z','a'..'z','0'..'9','_'.
			-- When Result is true, `last_keyword' is updated.
		require
			not keyword.empty
		local
			i, keyword_count: INTEGER
		do
			keyword_count := keyword.count
			from
				start_column := column
			until
				i = keyword_count or else cc /= keyword.item (i+1)
			loop
				i := i + 1
				next_char
			end
			if i = keyword_count then
				inspect cc
				when ' ','%N','%T','-' then
					Result := true
					last_keyword := keyword
					skip_space
				when 'a'..'z','A'..'Z','0'..'9','_' then
					from
					until
						i = 0
					loop
						prev_char
						i := i - 1
					end
				else
					Result := true
					last_keyword := keyword
				end
			else
				from
				until
					i = 0
				loop
					prev_char
					i := i - 1
				end
			end
		end

feature {NONE}

	last_keyword: STRING
	last_manifest_constant: CONSTANT_AS
	last_boolean_constant: BOOL_AS
	last_void_constant: VOID_AS
	last_character_constant: CHAR_AS
	last_real_constant: REAL_AS
	last_integer_constant: INTEGER_AS
	last_integer: INTEGER
	last_manifest_string: STRING_AS
	last_identifier: ID_AS
	last_dynamic_arg: DYNAMIC_ARG_AS
	last_subscript: SUBSCRIPT_ARGUMENT_AS
	last_bracketed: BRACKETED_AS
	last_accessible: ACCESSIBLE_FEATURE
	last_feature_call: FEATURE_CALL_AS
	last_feature: FEATURE_AS
	last_value: VALUE_AS
	last_in_expr: IN_AS
	last_likeable: LIKEABLE_AS
	last_like: LIKE_AS
	last_comparison: COMPARISON_AS
	last_boolean_expression: BOOLEAN_EXPRESSION_AS

	is_letter (c: CHARACTER): BOOLEAN is
		local
			c_code: INTEGER
		do
			c_code := c.code
			Result := (c_code >= ('A').code and c_code <= ('Z').code) or
						(c_code >= ('a').code and c_code <= ('z').code)
		end

	and_str: STRING is "and"
	or_str: STRING is "or"
	not_str: STRING is "not"
	like_str: STRING is "like"
	in_str: STRING is "in"
	true_str: STRING is "true"
	false_str: STRING is "false"
	void_str: STRING is "void"


	isa_keyword (s: STRING): BOOLEAN is
		require
			string_not_void: s /= Void
		do
			Result := s.is_equal (and_str) or s.is_equal (or_str) or
						s.is_equal (not_str) or s.is_equal (like_str) or
						s.is_equal (in_str) or s.is_equal (true_str) or
						s.is_equal (false_str) or s.is_equal (void_str)
		end

	feature_call_top: INTEGER

	feature_call_stack: ARRAY [ACCESSIBLE_FEATURE] is
		once
			!!Result.make (1,100)
			feature_call_top := 1
		end

	a_boolean_expression: BOOLEAN is
		do
			Result := a_boolean_expression1
			build_or
		end

	build_or is
		local
			val1, val2: like last_boolean_expression
		do
			if a_keyword (or_str) then
				val1 := last_boolean_expression
				if a_boolean_expression1 then
					val2 := last_boolean_expression
					!OR_AS!last_boolean_expression.make (val1, val2)
					build_or
				else
					syntax_error := true
				end
			end
		end

	a_boolean_expression1: BOOLEAN is
		do
			Result := a_boolean_expression2
			build_and
		end

	build_and is
		local
			val1, val2: like last_boolean_expression
		do
			if a_keyword (and_str) then
				val1 := last_boolean_expression
				if a_boolean_expression2 then
					val2 := last_boolean_expression
					!AND_AS!last_boolean_expression.make (val1, val2)
					build_and
				else
					syntax_error := true
				end
			end
		end

	a_boolean_expression2: BOOLEAN is
		local
			val1: like last_boolean_expression
		do
			if a_keyword (not_str) then
				if a_boolean_expression2 then
					Result := true
					val1 := last_boolean_expression
					!NOT_AS!last_boolean_expression.make (val1)
				else
					syntax_error := true
				end
			else
				Result := a_boolean_expression3
			end
		end

	a_boolean_expression3: BOOLEAN is
			-- "(" boolean_expression ")"
		local
			val1: like last_boolean_expression
		do
			if skip1 ('(') then
				Result := True
				if a_boolean_expression then
					val1 := last_boolean_expression
					if skip1 (')') then
						Result := true
						!PARAN_AS!last_boolean_expression.make (val1)
					else
						syntax_error := true
					end
				else
					syntax_error := true
				end
			elseif a_comparison then
				Result := true
				last_boolean_expression := last_comparison
			elseif a_like then
				Result := true
				last_boolean_expression := last_like
			elseif a_in_expr then
				Result := true
				last_boolean_expression := last_in_expr
			end
		end

	a_comparison: BOOLEAN is
		local
			c: INTEGER
			val1: like last_feature_call
		do
			c := column
			if a_feature_call then
				val1 := last_feature_call
				if skip1 ('=') then
					if a_value then
						Result := true
						!EQ_AS!last_comparison.make (val1, last_value)
					else
						syntax_error := true
					end
				elseif skip2 ('/','=') then
					if a_value then
						Result := true
						!NE_AS!last_comparison.make (val1, last_value)
					else
						syntax_error := true
					end
				elseif skip2 ('<','=') then
					if a_value then
						Result := true
						!LE_AS!last_comparison.make (val1, last_value)
					else
						syntax_error := true
					end
				elseif skip2 ('>','=') then
					if a_value then
						Result := true
						!GE_AS!last_comparison.make (val1, last_value)
					else
						syntax_error := true
					end
				elseif skip1 ('<') then
					if a_value then
						Result := true
						!LT_AS!last_comparison.make (val1, last_value)
					else
						syntax_error := true
					end
				elseif skip1 ('>') then
					if a_value then
						Result := true
						!GT_AS!last_comparison.make (val1, last_value)
					else
						syntax_error := true
					end
				else
					go_back_at (c)
				end
			end
		end

	a_like: BOOLEAN is
		local
			c: INTEGER
			feat_call: like last_feature_call
		do
			c := column
			if a_feature_call then
				feat_call := last_feature_call
				if a_keyword (like_str) then
					if a_likeable then
						Result := true
						!!last_like.make (feat_call, last_likeable)
					else
						syntax_error := true
					end
				else
					go_back_at (c)
				end
			end
		end

	a_likeable: BOOLEAN is
		do
			if a_dynamic_arg then
				Result := true
				last_likeable := last_dynamic_arg
			elseif a_manifest_string then
				Result := true
				last_likeable := last_manifest_string
			end
		end

	a_in_expr: BOOLEAN is
		local
			c: INTEGER
			val: like last_value
		do
			c := column
			if a_value then
				val := last_value
				if a_keyword (in_str) then
					if a_feature then
						Result := true
						!!last_in_expr.make (val, last_feature)
					else
						syntax_error := true
					end
				else
					go_back_at (c)
				end
			end
		end

	a_value: BOOLEAN is
		do
			if a_manifest_constant then
				Result := true
				last_value := last_manifest_constant
			elseif a_feature then
				Result := true
				last_value := last_feature
			end
		end

	a_feature: BOOLEAN is
		do
			if a_dynamic_arg then
				Result := true
				last_feature := last_dynamic_arg
			elseif a_feature_call then
				Result := true
				last_feature := last_feature_call
			end
		end

	a_feature_call: BOOLEAN is
		do
			if an_accessible then
				Result := true
				feature_call_top := 1
				if last_accessible /= Void then
					feature_call_stack.put (last_accessible, feature_call_top)
					feature_call_top := feature_call_top + 1
				end
				if cc = '.' then
					next_char
					if a_remote_call then
						!!last_feature_call.make (
								feature_call_stack.subarray (1, feature_call_top -1))
						feature_call_stack.make (1,100)
						feature_call_top := 1
					else
						syntax_error := true
						feature_call_stack.make (1,100)
						feature_call_top := 1
					end
				else
					!!last_feature_call.make (
							feature_call_stack.subarray (1, feature_call_top -1))
					feature_call_stack.make (1,100)
					feature_call_top := 1
				end
			end
		end

	a_remote_call: BOOLEAN is
		do
			if an_accessible then
				Result := true
				if last_accessible /= Void then
					feature_call_stack.put (last_accessible, feature_call_top)
					feature_call_top := feature_call_top + 1
				end
				if cc = '.' then
					next_char
					if not a_remote_call then
						syntax_error := true
					end
				end
			end
		end

	an_accessible: BOOLEAN is
		do
			if a_bracket then
				Result := true
				last_accessible := last_bracketed
			elseif a_identifier then
				Result := true
				last_accessible := last_identifier
			end
		end

	a_bracket: BOOLEAN is
		local
			c: INTEGER
			lid: like last_identifier
		do
			c := column
			if a_identifier then
				lid := last_identifier
				skip_space
				if cc = '[' then
					Result := True
					next_char
					skip_space
					if a_subscript then
						!!last_bracketed.make (lid, last_subscript)
						if cc /= ']' then
							syntax_error := true
						else
							next_char
							skip_space
						end
					else
						syntax_error := true
					end
				else
					go_back_at (c)
				end
			end
		end

	a_subscript: BOOLEAN is
		do
			if a_dynamic_arg then
				last_subscript := last_dynamic_arg
				Result := true
				skip_space
			elseif a_integer_constant then
				last_subscript := last_integer_constant
				Result := true
				skip_space
			end
		end

	a_dynamic_arg: BOOLEAN is
		do
			if skip1 ('$') then
				if a_integer then
					Result := true
					!!last_dynamic_arg.make (last_integer)
					skip_space
				else
					syntax_error := true
				end
			end
		end

	a_identifier: BOOLEAN is
		local
			done: BOOLEAN
			c: INTEGER
		do
			c := column
			if is_letter (cc) then
				from
					tmp_string.wipe_out
					tmp_string.extend (cc)
				until
					done
				loop
					next_char
					inspect cc
					when 'a'..'z','0'..'9','_','A'..'Z' then
						tmp_string.extend (cc)
					else
						done := true
					end
				end
				if isa_keyword (tmp_string) then
					go_back_at (c)
				else
					Result := true
					!!last_identifier.make (tmp_string)
					skip_space
				end
			end
		end

	a_manifest_constant: BOOLEAN is
			-- manifest_constant -> boolean_constant | character_constant |
			--                      real_constant | integer_constant |
			--                      manifest_string
		do
			if a_boolean_constant then
				last_manifest_constant := last_boolean_constant
				Result := true
			elseif a_void_constant then
				last_manifest_constant := last_void_constant
				Result := true
			elseif a_character_constant then
				last_manifest_constant := last_character_constant
				Result := true
			elseif a_real_constant then
				last_manifest_constant := last_real_constant
				Result := true
			elseif a_integer_constant then
				last_manifest_constant := last_integer_constant
				Result := true
			elseif a_manifest_string then
				last_manifest_constant := last_manifest_string
				Result := true
			end
		end

	a_boolean_constant: BOOLEAN is
			-- boolean_constant -> "true" | "false"
		do
			if a_keyword (true_str) then
				!!last_boolean_constant.make (true)
				Result := true
			elseif a_keyword (false_str) then
				!!last_boolean_constant.make (false)
				Result := true
			end
		end

	a_void_constant: BOOLEAN is
			-- void_constant -> "void"
		do
			if a_keyword (void_str) then
				!!last_void_constant
				Result := true
			end
		end

	a_character_constant: BOOLEAN is
		local
			value: CHARACTER
		do
			if cc = '%'' then
				next_char
				if cc = '%'' then
					syntax_error := true
				else
					Result := true
					value := cc
					next_char
					if cc /= '%'' then
						syntax_error := true
					end
				end
				skip_space
				!!last_character_constant.make (value)
			end
		end

	a_real_constant: BOOLEAN is
			-- real_constant -> ["+" | "-"] real
		local
			c: INTEGER
		do
			c := column
			if skip1 ('+') then
				if a_real then
					Result := true
				else
					go_back_at (c)
				end
			elseif skip1 ('-') then
				if a_real then
					last_real_constant.unary_minus
					Result := true
				else
					go_back_at (c)
				end
			elseif a_real then
				Result := true
			end
		end

	a_integer_constant: BOOLEAN is
			-- integer_constant -> ["+" | "-"] integer
		do
			if skip1 ('+') then
				if a_integer then
					!!last_integer_constant.make (last_integer)
					Result := true
				else
					syntax_error := true
				end
			elseif skip1 ('-') then
				if a_integer then
					!!last_integer_constant.make (-last_integer)
					Result := true
				else
					syntax_error := true
				end
			else
				Result := a_integer
				if Result then
					!!last_integer_constant.make (last_integer)
				end
			end
		end

	a_manifest_string: BOOLEAN is
		do
			if cc = '%"' then
				from
					next_char
					tmp_string.wipe_out
				until
					cc = '%"' or cc = end_of_text
				loop
					tmp_string.extend (cc)
					next_char
				end
				if cc = end_of_text then
					syntax_error := true
				else
					Result := true
					!!last_manifest_string.make (tmp_string.twin)
					next_char
					skip_space
				end
			end
		end

	zero_dot_str: STRING is "0."

	tmp_string: STRING is
		once
			!!Result.make (80)
		end

	a_real: BOOLEAN is
		local
			state, c: INTEGER
				-- state 0 : reading integral part.
				-- state 1 : '.' read and not empty integral_part.
				-- state 2 : '.' read and empty integral_part.
				-- state 3 : reading frac_part.
				-- state 4 : 'E' or 'e' read.
				-- state 5 : reading exponent.
				-- state 6 : happy end.
				-- state 7 : error end.
		do
			if cc.is_digit or else cc = '.' then
				from
					c := column
					tmp_string.wipe_out
					if cc = '.' then
						tmp_string.append (zero_dot_str)
						state := 2
					else
						tmp_string.extend (cc)
					end
				until
					state > 5
				loop
					next_char
					inspect state
					when 0 then
						inspect cc
						when '0' .. '9' then
							tmp_string.extend (cc)
						when '.' then
							tmp_string.extend ('.')
							state := 1
						else
							state := 7
						end
					when 1 then
						inspect cc
						when '0'..'9' then
							tmp_string.extend(cc)
							state := 3
						when 'E','e' then
							tmp_string.extend('E')
							state := 4
						else
							state := 6
						end
					when 2 then
						inspect cc
						when '0'..'9' then
							tmp_string.extend(cc)
							state := 3
						else
							state := 7
						end
					when 3 then
						inspect cc
						when '0'..'9' then
							tmp_string.extend(cc)
						when 'E','e' then
							tmp_string.extend('E')
							state := 4
						else
							state := 6
						end
					when 4 then
						inspect cc
						when '+' then
							state := 5
						when '-' then
							tmp_string.extend('-')
							state := 5
						when '0'..'9' then
							tmp_string.extend(cc)
							state := 5
						else
							syntax_error := true
							state := 7
						end
					else -- state = 5
						inspect cc
						when '0'..'9' then
							tmp_string.extend(cc)
						else
							state := 6
						end
					end
				end
				if state = 6 then
					!!last_real_constant.make (tmp_string.twin)
					Result := true
					skip_space
				else
					go_back_at (c)
				end
			end
		end

	a_integer: BOOLEAN is
		local
			done: BOOLEAN
			value, zero_code: INTEGER
		do
			if cc.is_digit then
				zero_code := ('0').code
				from
					Result := true
					start_column := column
					value := cc.code - zero_code
				until
					done
				loop
					next_char
					inspect cc
					when '0'..'9' then
						value := value * 10 + (cc.code - zero_code)
					else
						done := true
					end
				end
				if cc.is_alpha then
					syntax_error := true
				end
				last_integer := value
				skip_space
			end
		end

end -- class ABSTRACT_TREE_BUILDER

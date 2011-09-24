-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class BYTE_CODE

inherit

	BYTE_CODE_CONSTANT

	DB_GLOBAL_INFO

	DB_CONSTANTS

	EIFFEL_EXTERNALS

	SHARED_INTERNAL_INFOS

creation

	make

feature

	bcode: ARRAY [INTEGER]

	booleans: ARRAY [BOOLEAN]

	characters: ARRAY [CHARACTER]

	doubles: ARRAY [DOUBLE]

	strings: ARRAY [STRING]

feature

	make (lbcode: like bcode) is
		do
			bcode := lbcode
		end

	set_bool_values (lbooleans: like booleans) is
		do
			booleans := lbooleans
		end

	set_char_values (lcharacters: like characters) is
		do
			characters := lcharacters
		end

	set_dbl_values (ldoubles: like doubles) is
		do
			doubles := ldoubles
		end

	set_string_values (lstrings: like strings) is
		do
			strings := lstrings
		end

feature
	-- Evaluation

	current_position: INTEGER

	parameters: ARRAY [NODE_VALUE]

	current_object: ANY

	set_new_parameters (query_arguments: ARRAY[ANY]) is
		local
			i, total: INTEGER
		do
			if query_arguments /= Void then
				from
					total := query_arguments.count
					!!parameters.make (1, total)
					i := 1
				until
					i > total
				loop
					parameters.put (get_node_value (query_arguments @ i), i)
					i := i + 1
				end
			else
				parameters := Void
			end
		end

	fulfill_criteria (element: ANY): BOOLEAN is
		do
			current_object := element
			Result := evaluate
		end

	flush is
		do
			current_object := Void
			parameters := Void
		end

	ex: EXCEPTIONS is
		once
			!!Result
		end

	eat_one_position: INTEGER is
		do
			Result := bcode @ current_position
			current_position := current_position + 1
		end

	evaluate: BOOLEAN is
		local
			evaluation: NODE_VALUE
		do
			current_position := 1
			evaluation := recursive_interpreter
			debug ("select_query")
				if not evaluation.is_boolean then
					ex.raise ("Query returns a non boolean type")
				end
			end
			Result := evaluation.boolean_value
		end

	recursive_interpreter: NODE_VALUE is
		local
			operator: INTEGER
			first_operand, second_operand: NODE_VALUE
			second_length: INTEGER
			nb_calls, i: INTEGER
			saved_object: ANY
		do
			operator := eat_one_position
			inspect operator
			when AND_BC then
				second_length := eat_one_position
				Result := recursive_interpreter
				debug ("select_query")
					if not Result.is_boolean then
						ex.raise ("Left of AND not boolean")
					end
				end
				if Result.boolean_value then
					Result := recursive_interpreter
					debug ("select_query")
						if not Result.is_boolean then
							ex.raise ("Right of AND not boolean")
						end
					end
				else
					current_position := current_position + second_length
				end
			when BOOL_BC then
				!!Result.make_as_boolean (booleans @ eat_one_position)
			when BRACKETED_BC then
				first_operand := recursive_interpreter
				second_operand := recursive_interpreter
				debug ("select_query")
					if not first_operand.is_list then
						ex.raise ("[ ] applied on non list")
					end
					if not second_operand.is_integer then
						ex.raise ("subscript of [ ] not integer")
					end
				end
				Result := get_node_value (first_operand.list_value.i_th
								(second_operand.integer_value + 1))
			when CHAR_BC then
				!!Result.make_as_character (characters @ eat_one_position)
			when DYNAMIC_BC then
				Result := parameters @ eat_one_position
			when EQ_BC then
				first_operand := recursive_interpreter
				second_operand := recursive_interpreter
				!!Result.make_as_boolean (first_operand |== second_operand)
			when FEATCALL_BC then
				nb_calls := eat_one_position
				saved_object := current_object
				from
					i := 1
				until
					i > nb_calls
				loop
					first_operand := recursive_interpreter
					if i < nb_calls then
						debug ("select_query")
							if not first_operand.is_reference then
								ex.raise ("Feature call on non reference")
							end
						end

						current_object := first_operand.reference_value

						debug ("select_query")
							if current_object = Void then
								ex.raise ("Feature call on Void reference")
							end
						end
					end
					i := i + 1
				end
				Result := first_operand
				current_object := saved_object
			when GE_BC then
				first_operand := recursive_interpreter
				second_operand := recursive_interpreter
				!!Result.make_as_boolean (first_operand >= second_operand)
			when GT_BC then
				first_operand := recursive_interpreter
				second_operand := recursive_interpreter
				!!Result.make_as_boolean (first_operand > second_operand)
			when ID_BC then
				Result := eval_attribute (strings @ eat_one_position)
			when IN_BC then
				first_operand := recursive_interpreter
				second_operand := recursive_interpreter
				debug ("select_query")
					if not second_operand.is_list_or_array then
						ex.raise ("IN applied on non list and non array")
					end
					if first_operand.value = Void then
						ex.raise ("IN tested for Void")
					end
				end
				if second_operand.is_list then
					!!Result.make_as_boolean (second_operand.list_value.has (first_operand.value))
				else
					!!Result.make_as_boolean (second_operand.array_value.has (first_operand.value))
				end
			when INT_BC then
				!!Result.make_as_integer (eat_one_position)
			when LE_BC then
				first_operand := recursive_interpreter
				second_operand := recursive_interpreter
				!!Result.make_as_boolean (first_operand <= second_operand)
			when LIKE_BC then
				first_operand := recursive_interpreter
				second_operand := recursive_interpreter
				debug ("select_query")
					if not first_operand.is_string then
						ex.raise ("Left of LIKE not a string")
					end
					if not second_operand.is_string then
						ex.raise ("Right of LIKE not a string")
					end
				end
				!!Result.make_as_boolean (
					match_wild_card ($(first_operand.string_value.to_c),
										$(second_operand.string_value.to_c)))
			when LT_BC then
				first_operand := recursive_interpreter
				second_operand := recursive_interpreter
				!!Result.make_as_boolean (first_operand < second_operand)
			when NE_BC then
				first_operand := recursive_interpreter
				second_operand := recursive_interpreter
				!!Result.make_as_boolean (first_operand |!= second_operand)
			when NOT_BC then
				Result := recursive_interpreter
				debug ("select_query")
					if not Result.is_boolean then
						ex.raise ("NOT applied on non boolean")
					end
				end
				Result.remake_as_boolean (not Result.boolean_value)
			when OR_BC then
				second_length := eat_one_position
				Result := recursive_interpreter
				debug ("select_query")
					if not Result.is_boolean then
						ex.raise ("Left of OR not boolean")
					end
				end
				if not Result.boolean_value then
					Result := recursive_interpreter
					debug ("select_query")
						if not Result.is_boolean then
							ex.raise ("Right of OR not boolean")
						end
					end
				else
					current_position := current_position + second_length
				end
			when PARAN_BC then
				Result := recursive_interpreter
			when REAL_BC then
				!!Result.make_as_double (doubles @ eat_one_position)
			when STR_BC then
				!!Result.make_as_string (strings @ eat_one_position)
			when VOID_BC then
				!!Result.make_as_reference (Void)
			end
		end

	get_node_value (a_value: ANY): NODE_VALUE is
		local
			str: STRING
			array: ARRAY [ANY]
			list: RLIST [ANY]
			double_ref: DOUBLE_REF
			integer_ref: INTEGER_REF
			character_ref: CHARACTER_REF
			boolean_ref: BOOLEAN_REF
		do
			if a_value /= Void then
				array ?= a_value
				list ?= a_value
				str ?= a_value
				double_ref ?= a_value
				integer_ref ?= a_value
				character_ref ?= a_value
				boolean_ref ?= a_value
				if array /= Void then
					!!Result.make_as_array (array)
				elseif list /= Void then
					!!Result.make_as_list (list)
				elseif str /= Void then
					!!Result.make_as_string (str)
				elseif double_ref /= Void then
					!!Result.make_as_double (double_ref.item)
				elseif integer_ref /= Void then
					!!Result.make_as_integer (integer_ref.item)
				elseif character_ref /= Void then
					!!Result.make_as_character (character_ref.item)
				elseif boolean_ref /= Void then
					!!Result.make_as_boolean (boolean_ref.item)
				else
					!!Result.make_as_reference (a_value)
				end
			else
				!!Result.make_as_reference (Void)
			end
		end

	eval_attribute (attr_name: STRING): NODE_VALUE is
			-- Evaluate attribute `attr_name' in current_object
		local
			pclass: PCLASS
			pobject: POBJECT
			pattribute: PATTRIBUTE
			list: RLIST [ANY]
			array: ARRAY [ANY]
			string: STRING
			pobj: POBJECT
			attr_index: INTEGER
			obj: ANY
		do
			-- Look for a PCLASS and PATTRIBUTE
			pobject ?= current_object
			if pobject /= void then
				pclass := pobject.pobject_class
				if pclass = Void then
					pclass := pobject.get_our_class
				end
				if pclass /= void then
					pattribute := pclass.attributes.item (attr_name)
				end
			end
 
			if pattribute /= void then
				-- If the object and the attribute is persistent
				-- Use Versant class structure informations
				-- Much faster than INTERNAL
				debug ("select_query")
					if pattribute.eiffel_type_code = Eiffel_pointer then
						ex.raise ("Query on a vstr type")
					end
				end

				inspect pattribute.eiffel_type_code
				when Eiffel_boolean then
					!!Result.make_as_boolean (extract_boolean (
							pattribute.eiffel_offset, $current_object))
				when Eiffel_char then
					!!Result.make_as_character (extract_character (
							pattribute.eiffel_offset, $current_object))
				when Eiffel_double then
					!!Result.make_as_double (extract_double (
							pattribute.eiffel_offset, $current_object))
				when Eiffel_integer then
					!!Result.make_as_integer (extract_integer (
							pattribute.eiffel_offset, $current_object))
				when Eiffel_string then
					!!Result.make_as_string (extract_string (
							pattribute.eiffel_offset, $current_object))
				when Eiffel_object_key, Eiffel_object then
					pobj := extract_reference (pattribute.eiffel_offset,
								   $current_object)
					list ?= pobj
					array ?= pobj
					if array /= void then
						!!Result.make_as_array (array)
					elseif list /= void then
						!!Result.make_as_list (list)
					else
						!!Result.make_as_reference (pobj)
					end
				end
			else
				-- If the object or the attribute is not persistent
				-- Use INTERNAL
				attr_index := attribute_index_of (current_object, attr_name)

				debug ("select_query")
					if attr_index = 0 then
						ex.raise ("Query on a non existing attribute")
					elseif field_type(attr_index,current_object) = Real_type then
						ex.raise ("Query on a real")
					elseif field_type(attr_index,current_object) = Expanded_type then
						ex.raise ("Query on an expanded")
					elseif field_type(attr_index,current_object) = Bit_type then
						ex.raise ("Query on a BIT")
					elseif field_type(attr_index,current_object) = Pointer_type then
						ex.raise ("Query on a pointer")
					end
				end

				inspect field_type (attr_index, current_object)
				when Reference_type then
					obj := field (attr_index, current_object)
					list ?= obj
					array ?= pobj
					if array /= void then
						!!Result.make_as_array (array)
					elseif list /= void then
						!!Result.make_as_list (list)
					else
						string ?= obj
						if string /= void then
							!!Result.make_as_string (string)
						else
							!!Result.make_as_reference (obj)
						end
					end
				when Character_type then
					!!Result.make_as_character (character_field (
							attr_index, current_object))
				when Boolean_type then
					!!Result.make_as_boolean (boolean_field (
							attr_index, current_object))
				when Integer_type then
					!!Result.make_as_integer (integer_field (
							attr_index, current_object))
				when Double_type then
					!!Result.make_as_double (double_field (
							attr_index, current_object))
				end
			end
		end

feature

	dump is
		do
			current_position := 1
			recursive_dumper
			io.new_line
		end

	recursive_dumper is
		local
			operator: INTEGER
			nb_calls, i: INTEGER
			second_length: INTEGER
		do
			operator := eat_one_position
			inspect operator
			when AND_BC then
				second_length := eat_one_position
				recursive_dumper
				io.putstring (" and ")
				recursive_dumper
			when BOOL_BC then
				io.putbool (booleans @ eat_one_position)
			when BRACKETED_BC then
				recursive_dumper
				io.putstring ("[")
				recursive_dumper
				io.putstring ("]")
			when CHAR_BC then
				io.putchar (characters @ eat_one_position)
			when DYNAMIC_BC then
				io.putstring ("$")
				io.putint (eat_one_position)
			when EQ_BC then
				recursive_dumper
				io.putstring (" = ")
				recursive_dumper
			when FEATCALL_BC then
				nb_calls := eat_one_position
				from
					i := 1
				until
					i > nb_calls
				loop
					recursive_dumper
					if i < nb_calls then
						io.putstring (".")
					end
					i := i + 1
				end
			when GE_BC then
				recursive_dumper
				io.putstring (" >= ")
				recursive_dumper
			when GT_BC then
				recursive_dumper
				io.putstring (" > ")
				recursive_dumper
			when ID_BC then
				io.putstring (strings @ eat_one_position)
			when IN_BC then
				recursive_dumper
				io.putstring (" in ")
				recursive_dumper
			when INT_BC then
				io.putint (eat_one_position)
			when LE_BC then
				recursive_dumper
				io.putstring (" <= ")
				recursive_dumper
			when LIKE_BC then
				recursive_dumper
				io.putstring (" like ")
				recursive_dumper
			when LT_BC then
				recursive_dumper
				io.putstring (" < ")
				recursive_dumper
			when NE_BC then
				recursive_dumper
				io.putstring (" /= ")
				recursive_dumper
			when NOT_BC then
				io.putstring ("not ")
				recursive_dumper
			when OR_BC then
				second_length := eat_one_position
				recursive_dumper
				io.putstring (" or ")
				recursive_dumper
			when PARAN_BC then
				io.putstring ("( ")
				recursive_dumper
				io.putstring (" )")
			when REAL_BC then
				io.putdouble (doubles @ eat_one_position)
			when STR_BC then
				io.putstring (strings @ eat_one_position)
			when VOID_BC then
				io.putstring ("void")
			end
		end

feature

	match_wild_card (str, pattern : POINTER) : BOOLEAN is
		external "C"
		end

end

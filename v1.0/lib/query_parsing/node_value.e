-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class NODE_VALUE

inherit

	INTERNAL

creation

	make_as_reference, make_as_string, make_as_list,
	make_as_integer, make_as_double, make_as_boolean,
	make_as_character, make_as_array

feature

	String_type: INTEGER is 9

	List_type: INTEGER is 10

	Array_type: INTEGER is 11

feature

	type: INTEGER

feature

	reference_value: ANY

	string_value: STRING

	array_value: ARRAY [ANY]

	list_value: RLIST [ANY]

	integer_value: INTEGER

	double_value: DOUBLE

	boolean_value: BOOLEAN

	character_value: CHARACTER

	flush_reference_value is
		do
			reference_value := Void
			list_value := Void
			array_value := void
		end

feature

	value: ANY is
		do
			inspect type
			when Reference_type then
				Result := reference_value
			when List_type then
				Result := list_value
			when String_type then
				Result := string_value
			when Integer_type then
				Result := integer_value
			when Double_type then
				Result := double_value
			when Character_type then
				Result := character_value
			when Boolean_type then
				Result := boolean_value
			when Array_type then
				Result := array_value
			end
		end

feature

	is_reference: BOOLEAN is
		do
			Result := type = Reference_type
		end

	is_string: BOOLEAN is
		do
			Result := type = String_type
		end

	is_list: BOOLEAN is
		do
			Result := type = List_type
		end

	is_array: BOOLEAN is
		do
			Result := type = Array_type
		end

	is_list_or_array: BOOLEAN is
		do
			Result := is_list or is_array
		end

	is_integer: BOOLEAN is
		do
			Result := type = Integer_type
		end

	is_double: BOOLEAN is
		do
			Result := type = Double_type
		end

	is_boolean: BOOLEAN is
		do
			Result := type = Boolean_type
		end

	is_character: BOOLEAN is
		do
			Result := type = Character_type
		end

feature {NONE}
		-- Only callable from creation statement

	make_as_reference (ref: ANY) is
		do
			type := Reference_type
			reference_value := ref
		end

	make_as_string (str: STRING) is
		do
			type := String_type
			string_value := str
		end

	make_as_list (lst: RLIST [ANY]) is
		do
			type := List_type
			list_value := lst
		end

	make_as_array (arr: ARRAY [ANY]) is
		do
			type := Array_type
			array_value := arr
		end

	make_as_integer (int: INTEGER) is
		do
			type := Integer_type
			integer_value := int
		end

	make_as_double (dbl: DOUBLE) is
		do
			type := Double_type
			double_value := dbl
		end

	make_as_boolean (bool: BOOLEAN) is
		do
			type := Boolean_type
			boolean_value := bool
		end

	make_as_character (char: CHARACTER) is
		do
			type := Character_type
			character_value := char
		end

feature

	remake_as_reference (ref: ANY) is
		require
			valid_type: type = Reference_type
		do
			reference_value := ref
		end

	remake_as_string (str: STRING) is
		require
			valid_type: type = String_type
		do
			string_value := str
		end

	remake_as_list (lst: RLIST [ANY]) is
		require
			valid_type: type = List_type
		do
			list_value := lst
		end

	remake_as_array (arr: ARRAY [ANY]) is
		require
			valid_type: type = Array_type
		do
			array_value := arr
		end

	remake_as_integer (int: INTEGER) is
		require
			valid_type: type = Integer_type
		do
			integer_value := int
		end

	remake_as_double (dbl: DOUBLE) is
		require
			valid_type: type = Double_type
		do
			double_value := dbl
		end

	remake_as_boolean (bool: BOOLEAN) is
		require
			valid_type: type = Boolean_type
		do
			boolean_value := bool
		end

	remake_as_character (char: CHARACTER) is
		require
			valid_type: type = Character_type
		do
			character_value := char
		end

feature

	valid_equal_test (other: like Current): BOOLEAN is
		do
			inspect type
			when Reference_type then
				Result := other.is_reference or else
					other.is_list or else
					other.is_array or else
					(other.is_string and reference_value = Void)
			when List_type then
				Result := other.is_list or else other.is_reference
			when Array_type then
				Result := other.is_array or else other.is_reference
			when String_type then
				Result := other.is_string or else
					(other.is_reference and other.reference_value = Void)
			when Double_type then
				Result := other.is_double or else other.is_integer
			when Integer_type, Character_type, Boolean_type then
				Result := type = other.type
			end
		end

	infix "|==" (other: like Current): BOOLEAN is
		require
			other_not_void: other /= Void
			valid_types: valid_equal_test (other)
		do
			inspect type
			when Reference_type then
				if other.is_reference then
					Result := reference_value = other.reference_value
				elseif other.is_string then
					Result := other.string_value = Void
				elseif other.is_list then
					Result := reference_value = other.list_value
				else
					Result := reference_value = other.array_value
				end
			when List_type then
				if other.is_reference then
					Result := list_value = other.reference_value
				else
					Result := list_value = other.list_value
				end
			when Array_type then
				if other.is_reference then
					Result := array_value = other.reference_value
				else
					Result := array_value = other.array_value
				end
			when String_type then
				if other.is_reference then
					Result := string_value = Void
				else
					Result := equal (string_value, other.string_value)
				end
			when Integer_type then
				Result := integer_value = other.integer_value
			when Double_type then
				if other.is_double then
					Result := double_value = other.double_value
				else
					-- Must be an integer
					Result := double_value = other.integer_value
				end
			when Character_type then
				Result := character_value = other.character_value
			when Boolean_type then
				Result := boolean_value = other.boolean_value
			end
		end

	infix "|!=" (other: like Current): BOOLEAN is
		require
			other_not_void: other /= Void
			valid_types: valid_equal_test (other)
		do
			Result := not (Current |== other)
		end

	valid_comparison_types (other: like Current): BOOLEAN is
		do
			inspect type
			when Reference_type then
				Result := other.is_string and reference_value = Void
			when List_type, Array_type then
				Result := False
			when String_type then
				Result := other.is_string or else
					(other.is_reference and other.reference_value = Void)
			when Double_type then
				Result := other.is_double or else other.is_integer
			when Integer_type, Character_type then
				Result := type = other.type
			when Boolean_type then
				Result := False
			end
		end

	infix ">=" (other: like Current): BOOLEAN is
		require
			other_not_void: other /= Void
			valid_types: valid_comparison_types (other)
		do
			inspect type
			when Reference_type then
				Result := other.string_value = Void
			when String_type then
				if other.is_reference then
					Result := True
				elseif string_value /= Void and other.string_value /= Void then
					Result := string_value >= other.string_value
				else
					Result := other.string_value = Void
				end
			when Integer_type then
				Result := integer_value >= other.integer_value
			when Double_type then
				if other.is_double then
					Result := double_value >= other.double_value
				else
					-- Must be an integer
					Result := double_value >= other.integer_value
				end
			when Character_type then
				Result := character_value >= other.character_value
			end
		end

	infix ">" (other: like Current): BOOLEAN is
		require
			other_not_void: other /= Void
			valid_types: valid_comparison_types (other)
		do
			inspect type
			when Reference_type then
				Result := False
			when String_type then
				if other.is_reference then
					Result := string_value /= Void
				elseif string_value /= Void and other.string_value /= Void then
					Result := string_value > other.string_value
				else
					Result := string_value /= Void
				end
			when Integer_type then
				Result := integer_value > other.integer_value
			when Double_type then
				if other.is_double then
					Result := double_value > other.double_value
				else
					-- Must be an integer
					Result := double_value > other.integer_value
				end
			when Character_type then
				Result := character_value > other.character_value
			end
		end

	infix "<=" (other: like Current): BOOLEAN is
		require
			other_not_void: other /= Void
			valid_types: valid_comparison_types (other)
		do
			inspect type
			when Reference_type then
				Result := True
			when String_type then
				if other.is_reference then
					Result := string_value = Void
				elseif string_value /= Void and other.string_value /= Void then
					Result := string_value <= other.string_value
				else
					Result := string_value = Void
				end
			when Integer_type then
				Result := integer_value <= other.integer_value
			when Double_type then
				if other.is_double then
					Result := double_value <= other.double_value
				else
					-- Must be an integer
					Result := double_value <= other.integer_value
				end
			when Character_type then
				Result := character_value <= other.character_value
			end
		end

	infix "<" (other: like Current): BOOLEAN is
		require
			other_not_void: other /= Void
			valid_types: valid_comparison_types (other)
		do
			inspect type
			when Reference_type then
				 Result := other.string_value /= Void
			when String_type then
				if other.is_reference then
					Result := False
				elseif string_value /= Void and other.string_value /= Void then
					Result := string_value < other.string_value
				else
					Result := other.string_value /= Void
				end
			when Integer_type then
				Result := integer_value < other.integer_value
			when Double_type then
				if other.is_double then
					Result := double_value < other.double_value
				else
					-- Must be an integer
					Result := double_value < other.integer_value
				end
			when Character_type then
				Result := character_value < other.character_value
			end
		end

end

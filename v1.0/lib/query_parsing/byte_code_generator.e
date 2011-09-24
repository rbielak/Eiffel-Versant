-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class BYTE_CODE_GENERATOR

creation

	make

feature

	bcode: FAST_LIST[INTEGER]

	bool_values: FAST_LIST [BOOLEAN]

	char_values: FAST_LIST [CHARACTER]

	dbl_values: FAST_LIST [DOUBLE]

	string_values: FAST_LIST [STRING]

feature

	make is
		do
			!!bcode.make
			!!bool_values.make
			!!char_values.make
			!!dbl_values.make
			!!string_values.make
		end

	add_bool_value (a_bool: BOOLEAN): INTEGER is
		do
			bool_values.extend (a_bool)
			Result := bool_values.count
		end

	add_char_value (a_char: CHARACTER): INTEGER is
		do
			char_values.extend (a_char)
			Result := char_values.count
		end

	add_dbl_value (a_dbl: DOUBLE): INTEGER is
		do
			dbl_values.extend (a_dbl)
			Result := dbl_values.count
		end

	add_string_value (a_string: STRING): INTEGER is
		do
			string_values.extend (a_string)
			Result := string_values.count
		end

feature

	byte_code: BYTE_CODE is
		do
			!!Result.make (bcode.to_array)
			if bool_values.count > 0 then
				Result.set_bool_values (bool_values.to_array)
			end
			if char_values.count > 0 then
				Result.set_char_values (char_values.to_array)
			end
			if dbl_values.count > 0 then
				Result.set_dbl_values (dbl_values.to_array)
			end
			if string_values.count > 0 then
				Result.set_string_values (string_values.to_array)
			end
		end

end

-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "predicate for string fields";
	database: "Versant"

class DB_STRING_PREDICATE

inherit

	DB_QUERY_PREDICATE[STRING]

creation
 
	make, make_empty, make_with_feature_access
 
feature
 
	make (attribute: STRING; new_value : STRING) is
		require
			name_ok: attribute /= Void
		local
			feat_access: FEATURE_ACCESS
		do
			!!feat_access.make_simple_attribute (attribute)
			make_with_feature_access (feat_access, new_value)
		end
  
	make_with_feature_access (lattribute_access: FEATURE_ACCESS;
				new_value : STRING) is
		require
			attribute_ok: lattribute_access /= Void
		do
			set_attribute_access (lattribute_access)
			value := new_value
			operation := db_equal
		end

feature {NONE}

	value_size: INTEGER is
		require else
			true
		do
			if value = Void then
				Result := 1
			else
				-- include the terminating null in the count
				Result := value.count + 1
			end
		end

	value_address: POINTER is
		require else
			true
		do
			if value /= Void then
				Result := c_to_address ($(value.to_c))
			else
				Result := c_to_address ($(empty_string.to_c))
			end
		end
	
	empty_string : STRING is ""
	
	key_type : INTEGER is 
		once
			Result := db_key_type_char
		end
	
	make_empty is
			-- Create a predicate with all fields empty
		do
		end

	extract_i_th_vstr_value (vstr : VSTR; index : INTEGER) : STRING is
			-- Extract i-th entry of a vstr
		do
			except.raise ("No string vstrs allowed");
		end;

	extract_db_value (pobject_id : INTEGER; l_attr_name : STRING) : STRING is
			-- Extract the actual value of approriate type
			-- from the database
		do
			Result := get_db_string_attr (pobject_id, $(l_attr_name.to_c))
			check_error;
		end;

	test_values (db_value, pred_value : STRING) : BOOLEAN is
		local
			tmp1, tmp2: ANY
		do
			debug ("query")
				io.putstring ("DB_STRING_PREDICATE:is_true - db_value=");
				io.putstring (db_value);
				io.putstring ("  value=");
				io.putstring (pred_value);
				io.new_line;
			end;
			inspect operation
			when db_equal then
				Result := equal (pred_value, db_value)
			when db_not_equal then
				Result := pred_value /= db_value
			when db_less_than then
				Result := pred_value < db_value
			when db_less_than_or_eq then
				Result := pred_value <= db_value
			when db_greater_than then
				Result := pred_value > db_value
			when db_greater_than_or_eq then
				Result := pred_value >= db_value
			when db_like then
				Result := match_wild_card ($(db_value.to_c), $(pred_value.to_c))
			end;
			debug ("query")
				io.putstring ("Result=")
				io.putstring (Result.out)
				io.new_line
			end
		end
	
	match_wild_card (str, pattern : POINTER) : BOOLEAN is
		external "C"
		end

end -- DB_STRING_REPDICATE

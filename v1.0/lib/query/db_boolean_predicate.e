-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "predicate for boolean attributes"

class DB_BOOLEAN_PREDICATE

inherit

	DB_QUERY_PREDICATE [BOOLEAN_REF]

creation

	make, make_empty, make_with_feature_access

feature
	
	make (attribute: STRING; new_value : BOOLEAN) is
		require
			name_ok: attribute /= Void
		local
			feat_access: FEATURE_ACCESS
		do
			!!feat_access.make_simple_attribute (attribute)
			make_with_feature_access (feat_access, new_value)
		end
	
	make_with_feature_access (lattribute_access: FEATURE_ACCESS;
				new_value : BOOLEAN) is
		require
			attribute_ok: lattribute_access /= Void
		do
			set_attribute_access (lattribute_access)
			value := new_value
			operation := db_equal
		end

feature {NONE}
	
	value_size : INTEGER is 1
	
	value_address: POINTER is
		require else
			True
		local
			p : POINTER
		do
			actual_value := value.item
			Result := c_to_address ($actual_value)
		end
	
	key_type: INTEGER is
		once
			Result := db_key_type_u1b
		end

	actual_value: BOOLEAN

	make_empty is 
		do
		end

	extract_i_th_vstr_value (vstr: VSTR; index: INTEGER): BOOLEAN_REF is
			-- Extract i-th entry of a vstr
		do
			except.raise ("Not implemented")
		end

	extract_db_value (pobject_id: INTEGER; l_attr_name: STRING): BOOLEAN_REF is
			-- Extract the actual value of approriate type
			-- from the database
		do
			Result := get_db_bool_attr (pobject_id, $(l_attr_name.to_c))
			check_error
		end;
	
	test_values (pred_value, db_value: BOOLEAN_REF): BOOLEAN is
		do
			inspect operation
			when db_equal then
				Result := pred_value.item = db_value.item
			when db_not_equal then
				Result := pred_value.item /= db_value.item
			else
				except.raise ("Can't do this comparison on Boolean")
			end
		end

end -- DB_BOOLEAN_PREDICATE

-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class SCHEMA_ATTR

creation
	
	make,
	make_as_key_link

feature
	
	name : STRING
			-- name of attribute
	
	type : STRING
			-- type of attribute
	
	is_a_list : BOOLEAN
			-- true if the atribbute is of the form "list (some_type)"
	
	
	is_key_link: BOOLEAN
			-- true if this is a weak link
	
	key_link_aux_info: STRING
			-- stuff that has to be stored together with
			-- the attribute
	
feature {NONE}
	
	make (new_name : STRING; new_type : STRING; l_is_list : BOOLEAN) is
		require
			new_name /= Void
			new_type /= Void
		do
			name := new_name;
			type := new_type;
			is_a_list := l_is_list;
		end
	

	make_as_key_link (new_name : STRING; new_type: STRING; aux_info: STRING) is
		require
			new_name /= Void
			new_type /= Void
		do
			name := new_name
			key_link_aux_info := aux_info
			type := new_type
			is_key_link := True
			is_a_list := False
		end

end -- SCHEMA_ATTR

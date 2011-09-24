-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class PATTRIBUTE 
	
inherit

	DB_CONSTANTS
	EIF_VERS_EXTERNALS
	VERSANT_EXTERNALS
	EIFFEL_EXTERNALS
	DB_GLOBAL_INFO
	VERSANT_POINTER_EXTERNALS

	
feature
	
	name: STRING
			-- Name of this attribute

feature -- Eiffel specific 
	
	eiffel_type_code : INTEGER
			-- Code for corresponding Eiffel types as defined in `eiffel_type'
	
	eiffel_offset: INTEGER
			-- Offset within Eiffel object (Index used in INTERNAL functions)
	

	eiffel_type: INTEGER is
			-- Eiffel type for this kind of PATTRIBUTE
		deferred 
		end

feature -- extract value of the attribute

	value_to_string (object_id: INTEGER): STRING is
			-- Return value of attribute as a STRING
		deferred
		end

	value_from_id (object_id: INTEGER): ANY is
			-- Return the value of this attribute, given the 
			-- persistent object ID
		deferred
		end
	
feature -- Versant specific 

	field_offset: INTEGER
			-- Versant offset to use when accessing the persistent attribute

	
	original_name: STRING
			-- Original name of this attribute, if it was
			-- redefined, Void otherwise
	
	type: STRING
			-- type of the attribute
	
	type_is_basic: BOOLEAN is
		deferred
		end

	class_id: INTEGER is
			-- Object ID of the class in which this attribute was
			-- first defined
		do
			Result := get_db_int_attr (pobject_id, $(("classid").to_c));
		end;
	
	attr_id: INTEGER is
			-- Object ID of the schema attribute object (if the
			-- attribute was renamed, this will be the ID of the
			-- original attribute)
		do
			Result := get_db_int_attr (pobject_id, $(("attrid").to_c));
		end

	repetition: INTEGER
			-- Count of how many times the type is repeated
			-- r = 1 - just once
			-- r > 1 - fixed array
			-- r = -1 - variable array
			-- r = -2 - a list

	pobject_id: INTEGER
			-- object ID of the schema object
	
	aux_info: STRING 
			-- extra info to be stored with the schema -
			-- used in KEY_ATTRIBUTE
	
	
	is_key_attribute : BOOLEAN is
			-- true, if this attribute can be used in
			-- forming a query to retrieve a unique object
		do
			Result := aux_info /= Void
		end

	set_aux_info (laux_info: STRING) is
			-- Set aux_info for the pattribute object
		do
			aux_info := laux_info
			if aux_info = Void then
				aux_ptr := default_pointer
			else
				if aux_ptr /= default_pointer then
					db_interface.c_deletevstr (aux_ptr)
					check_error
				end
				aux_ptr := db_interface.o_newvstr ($aux_ptr, aux_info.count + 1, 
												   $(aux_info.to_c))
				check_error
			end
		end

	
feature {META_PCLASS}	

	aux_ptr : POINTER 


feature {POBJECT}
	
	store_attr, store_shallow_attr (object: POBJECT; obj_ptr: POINTER) is
			-- store this attribute in the database
		require
			object /= Void
		deferred
		end

	retrieve_attr (object: POBJECT; obj_ptr: POINTER) is
			-- Retrieve this attribute from the database
		require
			object /= Void
		deferred
		end

	refresh_attr (object: POBJECT; deep: BOOLEAN; obj_ptr: POINTER) is
			-- Refresh this attribute from the database
			-- (deeply or shallowly)
		require
			object /= Void
		deferred
		end
	
	is_different (object: POBJECT; obj_ptr: POINTER) : BOOLEAN is
			-- Compare the value of the Eiffel and
			-- database attribute. Return "True" if they
			-- are different.
		require
			object /= Void
		deferred
		end

feature {PCLASS, META_PCLASS}
	
	set_name (new_name : STRING) is
			-- Rename the attribute
		require
			new_name /= Void
		do
			name := new_name
		end

	set_eiffel_offset (new_offset: INTEGER) is
		do
			eiffel_offset := new_offset
		end

	make (new_name: STRING; new_type: STRING; new_rep: INTEGER; pid: INTEGER;
			new_field_offset: INTEGER; new_aux_info: STRING) is
			-- Init the attribute
		require
			valid_name: new_name /= Void;
			valid_type: new_type /= Void;
			valid_rep: (new_rep >= -2);
			valid_id: pid /= 0;
		local
			tmp_name : STRING;
		do
			name := new_name;
			type := new_type;
			repetition := new_rep;
			aux_info := new_aux_info
			pobject_id := pid;
			field_offset := new_field_offset
			eiffel_offset := -1;
			eiffel_type_code := eiffel_type;
			-- see if this is a renamed attribute, if so
			-- find the original name
			tmp_name := get_db_string_attr (attr_id, $(("name").to_c));
			if not tmp_name.is_equal (name) then
				original_name := tmp_name
			end
		end;


feature {NONE}
	
	make_new (new_name : STRING; new_type : STRING; new_rep : INTEGER) is
			-- CHECK WITH RICHIE
			-- Make a new attribute object for a new
			-- class. Type here is the database type name
		require
			valid_name: new_name /= Void;
			valid_type: new_type /= Void;
			valid_rep: (new_rep >= -2);
		do
			name := clone(new_name);
			type := clone(new_type);
			repetition := new_rep;
			eiffel_offset := -1;
			eiffel_type_code := eiffel_type;			
		end; -- make_new


	is_basic_type (a_type: STRING): BOOLEAN is
		do
			Result := a_type.is_equal ("char") or a_type.is_equal ("o_u1b")
				or a_type.is_equal ("o_4b") or a_type.is_equal ("o_double")
		end
	
end -- PATTRIBUTE

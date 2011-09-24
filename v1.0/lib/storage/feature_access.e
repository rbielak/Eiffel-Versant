-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class FEATURE_ACCESS

inherit

	DB_CONSTANTS
	VERSANT_EXTERNALS
	DB_GLOBAL_INFO

creation

	make_simple_attribute,
	make_subscripted_attribute

feature

	attribute_name: STRING

	subscript: INTEGER

	is_dynamic_subscript: BOOLEAN

	next: FEATURE_ACCESS

feature

	make_simple_attribute (lname: STRING) is
		require
			name_not_void: lname /= Void
		do
			attribute_name := clone (lname)
			subscript := -1
		end

	make_subscripted_attribute (lname: STRING; lsubscript: INTEGER;
					dynamic: BOOLEAN) is
		require
			name_not_void: lname /= Void
			valid_subscript: lsubscript >= 0
		local
			ex: EXCEPTIONS
		do
			attribute_name := lname
			subscript := lsubscript
			is_dynamic_subscript := dynamic
			if is_dynamic_subscript then
				!!ex; ex.raise ("Dynamic Subscript in Query is not yet implemented")
			end
		end

	set_next (lfeature: FEATURE_ACCESS) is
		do
			next := lfeature
		end

feature

	get_last_name: STRING is
		do
			if next = Void then
				Result := attribute_name
			else
				Result := next.get_last_name
			end
		end

	get_last_subscript: INTEGER is
		do
			if next = Void then
				Result := subscript
			else
				Result := next.get_last_subscript
			end
		end

	area_str: STRING is "area"

	get_db_id (pobject_id: INTEGER): INTEGER is
		require
			pid_ok: pobject_id /= 0
			call_is_valid: next /= Void
		local
			area_vstr: VSTR
		do
			Result := get_db_int_attr (pobject_id, $(attribute_name.to_c))
			check_error
			if subscript >= 0 and Result /= 0 then
				!!area_vstr.make (get_db_ptr_attr (Result, $(area_str.to_c)))
				check_error
				if area_vstr.exists then
					Result := area_vstr.i_th_integer (subscript + 1)
				else
					Result := 0
				end
			end
			if Result > 0 and next.next /= Void then
				Result := next.get_db_id (Result)
			end
			if Result = 0 then
--				except.raise ("Cannot evaluate predicate - incomplete path")
			end
		end

feature -- Translation to PATTRIBUTEs
	
	pattribute: PATTRIBUTE
			-- persistent attribute that goes with the attribute
	
	find_pattributes (pclass: PCLASS) is
			-- find all pattributes starting given the PCLASS
		require
			pclass_valid: pclass /= Void
		local
			class_id: INTEGER
			collection_pclass: PCLASS
		do
			pattribute := pclass.attributes.item (attribute_name)
			-- Follow the path if there are more parts
			if next /= Void then
				if not pattribute.type_is_basic  then
					class_id := pclass.db.find_class_id (pattribute.type)
				else
					except.raise ("Error resolving attribute path")
				end
				if subscript = -1 then
					next.find_pattributes (db_interface.find_class_by_class_id (class_id))
				else
					collection_pclass := db_interface.find_class_by_class_id (class_id)
					next.find_pattributes (collection_pclass.pclass_of_generic)
				end
			end
		end

invariant
	
	valid_attr_name: attribute_name /= Void
	
end -- FEATURE_ACCESS

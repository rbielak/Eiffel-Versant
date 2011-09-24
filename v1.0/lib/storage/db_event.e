-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- DB_EVENT - describes a database event that can be published to 
-- other database users
--
class DB_EVENT

inherit
	
	DB_GLOBAL_INFO

creation

	make, make_with_loid

feature

	transaction: STRING
			-- transaction sending this event

	object: POBJECT
			-- object updated by this transaction

	loid: STRING 
			-- LOID of the updated object

	object_type: STRING
			-- Type of the updated object

	version_number: INTEGER
			-- version of the object when the event occured

	same_as (other_event: DB_EVENT): BOOLEAN is
			-- True is object and it's version number are the same
		require
			valid_event: other_event /= Void
		do
			Result := 
				(object = other_event.object) and then
				(object.pobject_version = other_event.object.pobject_version)
		end

feature 

	make_with_loid (ltransaction: STRING; l_loid: STRING; version: INTEGER) is
		require
			transaction_valid: ltransaction /= Void
			loid_valid: l_loid /= Void
		local
			obj_id: INTEGER
		do
			transaction := ltransaction
			obj_id := db_interface.c_scan_loid ($(l_loid.to_c))
			if obj_id /= 0 then
				object := db_interface.object_table.item (obj_id)
				version_number := version
				loid := l_loid
				if object /= Void then
					object_type := object.generator
				end
			else
				loid := "0.0.0"	
			end
		end

	make (ltransaction: STRING; lobject: POBJECT) is
		require
			transaction_valid: ltransaction /= Void
		do
			transaction := ltransaction
			object := lobject
			if object.pobject_id /= 0 then
				loid := object.external_object_id
			end
			if object /= Void then
				object_type := object.generator
			end
		end

	reset_version is
		do
			version_number := object.pobject_version
		end

invariant

	transaction_valid: transaction /= Void

end -- DB_EVENT

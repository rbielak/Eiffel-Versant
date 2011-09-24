-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class POBJECT_ROOT_ID_MODIFIER

inherit

	DB_INTERNAL

feature

	set_root_id (object: POBJECT; root_id: INTEGER) is
			-- force a root id into a new POBJECT.
		require
			root_id_valid: root_id /= 0
			object_transient: (object /= Void) and then (object.pobject_id = 0)
		do
			object.set_root_id (root_id)
		end

end
		

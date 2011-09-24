-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- META_PCLASS SERVER - class for retrieving META_PCLASSes
--

class META_PCLASS_SERVER

inherit
	
	DB_GLOBAL_INFO

feature
	
	meta_pclass_by_name (lname: STRING) : META_PCLASS is
			-- Return a META_PCLASS, if it's defined in
			-- the database. Return Void if not
		require
			name_ok: lname /= Void
		local
			pclass: PCLASS
			pclass_id: INTEGER
		do
			-- First find the PCLASS
			pclass := db_interface.find_class (lname)
			if pclass /= Void then
				--next, check the table
				Result := mpclass_table.item (pclass.pobject_id)
				
				if Result = Void then
					-- if not in the table, then create it
					!!Result.make_from_pclass (pclass)
					mpclass_table.put (Result, 
							   pclass.pobject_id)
				end
			end
		end
	
	meta_pclass_by_pclass_id (pclass_id: INTEGER) : META_PCLASS is
		require
			pclass_id_valid: pclass_id > 0
		local
			pclass: PCLASS
		do
			Result := mpclass_table.item (pclass_id)
			-- if not in the table yet, create it
			if Result = Void then
				pclass := db_interface.find_class_by_class_id (pclass_id)
				if pclass /= Void then
					!!Result.make_from_pclass (pclass)
					mpclass_table.put (Result, 
							   pclass.pobject_id)
				end
			end
		end
	
feature {NONE}
	
	mpclass_table: HASH_TABLE [META_PCLASS, INTEGER] is
			-- META_PCLASSes indexed by the object_id of
			-- the PCLASS
		once
			!!Result.make (100)
		end
		
	

end -- META_PCLASS_SERVER

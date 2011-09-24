-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Map nice types to Versant types
--

class TYPE_MAPPER

inherit

creation
	make

feature
	
	make is
		local
			ti : TYPE_INFO;
		do
			!!table.make (43);
			-- Populate the table
			!!ti.make ("char", -1);
			table.put (ti, "string");
			!!ti.make ("o_u1b", 1);
			table.put (ti, "boolean");
			!!ti.make ("o_4b", 1);
			table.put (ti, "integer");
			!!ti.make ("o_double", 1);
			table.put (ti, "real");
			table.put (ti, "double");
			!!ti.make ("char", 1);
			table.put (ti, "character");
			!!ti.make ("pobject", 1);
			table.put (ti, "object");
		end;
	
	item (type_name : STRING) : TYPE_INFO is
		require
			type_name /= Void
		do
			Result := table.item (type_name);
		end;
	
feature {NONE}
	
	table : HASH_TABLE [TYPE_INFO, STRING];

invariant

end -- TYPE_MAPPER

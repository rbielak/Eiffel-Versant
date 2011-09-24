-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing
	description: "Manage a collection of persistent objects"

class PERSISTENCY_ROOT[T->POBJECT]
	
inherit

	DB_GLOBAL_INFO
	
	SHARED_ROOT_SERVER

	STAMPED
		rename
			database as root_database
		redefine
			set_rights_stamp
		end

	PRIMARY_CONTAINER
		rename
			make as primary_container_make
		end

creation {ROOT_SERVER} 
	
	set_spec_from_root_info

feature

	root_name: STRING;
			-- name of the root

	
	root_id : INTEGER is
			-- Unique ID of the root
		require else
			root_available: available
		do
			Result := root_info.pobject_root_id
		end
	
	contents_type : STRING;
			-- generator for elements

	contents: CONCURRENT_PLIST [T];
			-- Contents of root
	
	store_differences is
			-- Store only objects that changed
		do
			if root_info /= Void then
				if not contents.has_write_lock then
					contents.write_lock_list
				end
				root_info.store_difference;
			end
		end
	
	refresh is
			-- Refresh the contents list
		do
			if root_info /= Void then
				root_info.refresh
			end
		end;
	
	
	available : BOOLEAN is
			-- True if the root is available for access
		do
			if (root_database /= Void) and then (root_database.is_connected) 
			 then
				Result := root_info /= Void
			end
		end
	
	root_database : DATABASE
			-- database in which this root resides
	
	
feature {PERSISTENT_ROOTS}
	

	store_obj (context: DB_OPERATION_CONTEXT) is
		do
			if root_info /= Void then
				root_info.store_obj (context)
			end
		end;
	
	refresh_obj (context: DB_OPERATION_CONTEXT) is
		do
			if root_info /= Void then
				root_info.refresh_obj (context)
			end
		end;
	

	check_diff_obj (make_new_persistent: BOOLEAN; context: DB_OPERATION_CONTEXT) is
		do
			if root_info /= Void then
				root_info.check_diff_obj (make_new_persistent, context)
			end
		end

	reset_stamp is
		do
			if root_info /= Void then
				rights_stamp := root_database.rights_stamp_by_id (root_id)
				root_info.reset_stamp
			end
		end

	set_rights_stamp (new_stamp : INTEGER) is
			-- Set the rights stamp for this root
		do
			rights_stamp := new_stamp
			if root_info /= Void then
				root_info.reset_rights_stamp (new_stamp)
			end
			if contents /= Void then
				contents.reset_rights_stamp (new_stamp)
			end
		end


feature {DATABASE, ROOT_SERVER, DB_INTERNAL}

	root_info: ROOT_INFO;
			-- The pesistent object representing this root
	
	reset_database is
		do
			root_database := root_info.database
		end

feature {NONE}
	

	register_as_persistent_root is
			-- Register this root in PERSISTENT_ROOTS if it must be
			-- entirely saved at the end of the process.
		local
			persistent_roots: PERSISTENT_ROOTS
		do
			!!persistent_roots
			if available then
				-- Don't register if the root isn't
				-- really here
				persistent_roots.register (Current)
			end
		end -- register_as_persistent_root



feature {ROOT_SERVER}
	
	set_spec_from_root_info (ri : ROOT_INFO) is
		require
			ri_there: ri /= Void
		local
			lstamp : INTEGER
		do
			root_info := ri;
			root_name := root_info.root_name;
			contents_type := root_info.root_contents_type;
			contents ?= root_info.contents;
			root_database := root_info.pobject_class.db;
--			!!contents_lock.make (contents);
			if root_info.register_root then
				register_as_persistent_root
			end
			-- Set up rights stamps
			lstamp := root_database.rights_stamp_by_id (root_id); 
			set_rights_stamp (lstamp);
			if root_info.eiffel_root = Void then
				root_info.set_eiffel_root (Current)
			elseif root_info.eiffel_root /= Current then
				except.raise ("Bad set_spec on persistency root")
			end
			primary_container_make
		end

feature {PERSISTENT_ROOTS}

	flush is
		do
			if not memory_items.empty then
				memory_items.clear_all
			end
		end

invariant
	
	root_name_valid: root_name /= Void
	
end -- persistency_root

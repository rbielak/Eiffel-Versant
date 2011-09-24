-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Access Rights stamp manipulation. Any object needing rights stamps
-- should inherit this class
--

deferred class STAMPED
	
inherit
	
	DB_GLOBAL_INFO

	ROOTED

feature -- Access rights for individual objects
	
	read_allowed : BOOLEAN is
		do
			Result := db_interface.c_check_read (rights_stamp)
			debug ("stamp")
				print ("read_allowed->")
				print (Result);
				io.new_line;
			end
		end
	
	write_allowed : BOOLEAN is
		do
			Result := db_interface.c_check_write (rights_stamp)
			debug ("stamp");
				print ("write_allowed->")
				print (Result);
				io.new_line;
			end
		end
	
feature -- Access rights for Persistency roots
	
	add_allowed : BOOLEAN is
			-- Can add new element
		do
			Result := db_interface.c_check_add (rights_stamp)
			debug ("stamp");
				print ("add_allowed->")
				print (Result);
				io.new_line;
			end
		end
	
	delete_allowed : BOOLEAN is
			-- Can delete an element
		do
			Result := db_interface.c_check_delete (rights_stamp)
			debug ("stamp");
				print ("delete_allowed->")
				print (Result);
				io.new_line;
			end
		end
	
	display_allowed : BOOLEAN is
			-- Can display in the UI
		do
			Result := db_interface.c_check_display (rights_stamp)
			debug ("stamp");
				print ("display_allowed->")
				print (Result);
				io.new_line;
			end
		end
	
feature

	set_rights_stamp (new_stamp : INTEGER) is
			-- OR the new stamp with the old onw, this way
			-- the rights will not decrease
		do
			rights_stamp := db_interface.c_or_stamps (new_stamp, rights_stamp);
		end

feature {STAMPED, DB_INTERFACE_INFO, PERSISTENT_ROOTS}
	

	reset_rights_stamp (new_stamp : INTEGER) is
			-- Reset the rights stamp
		do
			rights_stamp := new_stamp
		end

feature

	rights_stamp : INTEGER
			-- Stamp used for determining the rights a
			-- user has to this object
	

end -- STAMPED

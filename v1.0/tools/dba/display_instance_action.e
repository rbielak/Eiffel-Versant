-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DISPLAY_INSTANCE_ACTION

inherit 
	
	DBA_ACTION
	DB_GLOBAL_INFO

feature


	error_msg : STRING is "Cannot find instance"

	sub_action is
		local
			i: INTEGER
			pclass: PCLASS
			one_attr: PATTRIBUTE
		do
			if object_id = 0 then
				io.putstring ("Object doesn't exist. %N")
			else
				pclass := db_interface.find_class_for_object (object_id)
				io.new_line;
				io.putstring ("LOID : ")
				io.putstring (db_interface.c_get_loid (object_id))
				io.putstring (" Class : ")
				io.putstring (pclass.name)
				io.putstring (" Database : ")
				io.putstring (pclass.db.name)
				io.new_line
				io.putstring(" ")
				io.new_line
				from 
					i := 1
				until 
					i > pclass.attributes_array.count
				loop
					one_attr := pclass.attributes_array.item (i)
					if not one_attr.name.is_equal("peif_id") then
						io.putstring("  ")
						io.putstring (string_to_twenty (one_attr.name))
						io.putstring (" : ")
						io.putstring (one_attr.value_to_string (object_id))
						io.new_line
					end
					i := i + 1
					
				end -- loop
			end -- else
		end

	string_to_twenty (in : STRING) : STRING is
		local
			c: INTEGER
			s: STRING
		do
			s := in
			if (in.count < 20) then
				from
					c := in.count
				until
					c > 20
				loop
					s.append (" ")
					c := c+1
				end
			end
			Result := s
		end
   	
	
	object_id : INTEGER
	
	set_id (s: STRING) is
		do
			s.to_lower
			object_id := db_interface.c_scan_loid ($(s.to_c))
		end
			
	
end


	
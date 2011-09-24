-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DB_GLOBAL_INFO
	
feature
	
	db_interface : DB_INTERFACE_INFO is
			-- Global DB interface information
		once
			!!Result.make
		end;
	
feature{NONE}

	except : EXCEPTIONS is
		once
			!!Result
		end;


	
	check_error is
		local
			error_msg: STRING
			tmp: ANY
			obj: POBJECT
		do
			if db_interface.last_error /= 0 then
				!!error_msg.make (100);
				tmp := error_msg.to_c
				if db_interface.o_geterrormessage (db_interface.last_error, 
								   $tmp, error_msg.capacity) = 0
				 then
					error_msg.from_c ($tmp)
				else
					error_msg := "Versant error"
				end
				io.putstring ("*** ERROR: ");
				io.putint (db_interface.last_error);
				io.putstring (" -- ")
				io.putstring (error_msg)
				io.new_line
				obj ?= Current
				if (obj /= Void) and then (obj.pobject_id /= 0) then
					io.putstring ("In object LOID=<")
					io.putstring (obj.external_object_id)
					io.putstring (">%N")
				end
				io.putstring (out);
				io.new_line;
				except.raise (error_msg)
			end;
		end;


end -- DB_GLOBAL_INFO

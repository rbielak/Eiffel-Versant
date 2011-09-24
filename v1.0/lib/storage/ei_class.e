-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class EI_CLASS

creation

	make_from_name, make

feature
	
	

	Eif_No_Type: INTEGER is -1

	class_id: INTEGER

	make is
		do
			class_id := Eif_No_Type;
		end;

	make_from_name (cl_name: STRING) is
		require
			valid_class_name: cl_name /= Void
		do
			class_id := c_eif_id ($(cl_name.to_c))
		ensure
			valid_class_id: class_id /= Eif_No_Type
		end -- make_from_name

	allocate_object: ANY is
		do
			Result := c_eifcreate (class_id)
			debug
				io.putstring ("Allocating an object:%N")
				io.putstring (Result.out)
				io.new_line
			end
		end -- allocate_object

feature
	-- Externals

	c_eif_id (cl_name: POINTER): INTEGER is
		external "C"
		end -- c_eif_id
	
	c_eifcreate (cid: INTEGER): ANY is
		external "C"
		end -- c_eifcreate

end -- class EI_CLASS

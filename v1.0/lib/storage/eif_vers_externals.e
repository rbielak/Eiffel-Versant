-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Externals that use features from Eiffel runtime and
-- from versant library
--
class EIF_VERS_EXTERNALS

feature {DB_GLOBAL_INFO}


	c_int_retr (pobject_id : INTEGER; attr_name : ANY;
			attr_offset : INTEGER; obj : ANY) is
		external "C"
		end;
	
	c_int_o_retr (pobject_id : INTEGER; db_offset : INTEGER;
			attr_offset : INTEGER; obj : ANY) is
		external "C"
		end;

	c_int_o_retr_ptr (obj_ptr : POINTER; db_offset : INTEGER;
			attr_offset : INTEGER; obj : ANY) is
		external "C"
		end;

	c_ptr_o_retr_ptr (obj_ptr : POINTER; db_offset : INTEGER;
			attr_offset : INTEGER; obj : ANY) is
		external "C"
		end;

	c_bool_o_retr (pobject_id : INTEGER; db_offset : INTEGER;
			attr_offset : INTEGER; obj : ANY) is
		external "C"
		end;

	c_bool_o_retr_ptr (obj_ptr : POINTER; db_offset : INTEGER;
			attr_offset : INTEGER; obj : ANY) is
		external "C"
		end;

	c_char_o_retr (pobject_id : INTEGER; db_offset : INTEGER;
			attr_offset : INTEGER; obj : ANY) is
		external "C"
		end;

	c_char_o_retr_ptr (obj_ptr : POINTER; db_offset : INTEGER;
			attr_offset : INTEGER; obj : ANY) is
		external "C"
		end;

	c_double_retr (pobject_id : INTEGER; attr_name : ANY;
			attr_offset : INTEGER; obj : ANY) is
		external "C"
		end;

	c_double_o_retr (pobject_id : INTEGER; db_offset : INTEGER;
			attr_offset : INTEGER; obj : ANY) is
		external "C"
		end;

	c_double_o_retr_ptr (obj_ptr : POINTER; db_offset : INTEGER;
			attr_offset : INTEGER; obj : ANY) is
		external "C"
		end;

	c_set_session_active (active : BOOLEAN) is
		external "C"
		end;
	
	c_get_loid (object_id : INTEGER) : STRING is
		external "C"
		end;

end -- EIF_VERS_EXTERNALS

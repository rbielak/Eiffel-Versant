-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
--  Constants onlys
--

class DB_CONSTANTS

feature
	
	Eiffel_unknown_type,
	Eiffel_string,
	Eiffel_object,
	Eiffel_integer,
	Eiffel_double,
	Eiffel_char,
	Eiffel_boolean,
	Eiffel_pointer, 
	Eiffel_object_key : INTEGER is unique;

	
			-- Constants for comparison operations
	db_equal        : INTEGER is 0; -- O_EQ
	db_not_equal    : INTEGER is 1; -- O_NE	
	db_less_than    : INTEGER is 2; -- O_LT
	db_less_than_or_eq : INTEGER is 3; -- O_LE
	db_greater_than : INTEGER is 4; -- O_GT
	db_greater_than_or_eq : INTEGER is 5; -- O_GE
			-- Some extra operations for queries
	db_like         : INTEGER is 6; -- match regular expression
        db_in_list      : INTEGER is 7; -- see if element is in list
	
			-- Constants for building predicate blocks
	db_o_and        : INTEGER is 0; -- O_AND
	db_o_or         : INTEGER is 1; -- O_OR
	db_o_not        : INTEGER is 2; -- O_NOT
	
			-- types of keys
	db_key_type_unspecified : INTEGER is 0; -- O_UNSPECIFIED_TYPE
	db_key_type_char        : INTEGER is 1; -- O_CHAR_TYPE
	db_key_type_u1b    : INTEGER is 2; -- O_U1B_TYPE
	db_key_type_1b     : INTEGER is 3; -- O_1B_TYPE
	db_key_type_u2b    : INTEGER is 4; -- O_U2B_TYPE
	db_key_type_2b     : INTEGER is 5; -- O_2B_TYPE
	db_key_type_u4b    : INTEGER is 6; -- O_U4B_TYPE
	db_key_type_4b     : INTEGER is 7; -- O_4B_TYPE
	db_key_type_float  : INTEGER is 8; -- O_FLOAT_TYPE
	db_key_type_double : INTEGER is 9; -- O_DOUBLE_TYPE
	db_key_type_stptr  : INTEGER is 10; -- O_STPRT_TYPE
	db_key_type_object : INTEGER is 11; -- O_OBJECT_TYPE

			-- Lock constants
	db_no_lock    : INTEGER is 0;
	db_write_lock : INTEGER is 1;
	db_read_lock  : INTEGER is 3;
	
			-- Access rights constants
	read_write_allowed    : INTEGER is 15
	read_only_allowed     : INTEGER is 1
	display_and_read_allowed : INTEGER is 17
	read_write_display_allowed : INTEGER is 31
	max_roots_per_db    : INTEGER is 2048;
	
			-- Rescued DB errors
	path_select_multi_db_error: INTEGER is 1000
	weak_link_query_error: INTEGER is 5405
	cannot_send_event: INTEGER is 112

end -- DB_CONSTANTS

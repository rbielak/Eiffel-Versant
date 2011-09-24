-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--

class DATABASE_CONNECTOR

inherit
	
	SHARED_PRIVATE_DATA
		rename
			user_man as local_user_man,
			date_formatter as local_date_formatter,
			amount_formatter as local_amount_formatter,
			end_connection as local_end_connection,
			double_formatter as local_double_formatter,
			connection_active as local_connection_active,
			current_user as local_current_user,
			time_formatter as local_time_formatter,
			current_private_db as local_current_private_db,
			start_connection as local_start_connection,
			private_booking_center_man as local_private_booking_center_man,
			private_product_man as local_private_product_man,
			private_quote_series_man as local_private_quote_series_man,
			private_daily_data_man as local_private_daily_data_man,
			private_meta_parameter_man as local_private_meta_parameter_man,
			private_meta_model_man as local_private_meta_model_man,
			private_multi_booking_center_man as local_private_multi_booking_center_man
		end

	
	SHARED_ENV_VARS

feature
	
	database_name : STRING 
	
	set_database_name (new_name : STRING) is
		local
			server : STRING
		do
			database_name := new_name
			-- if the server name is not included, add it in
			if database_name.index_of ('@', 1) = 0 then
				server := env_vars.get ("DATABASE_SERVER")
				if server /= Void then
					database_name.append ("@")
					database_name.append (server)
				end
			end
		end
	
	connect is
		local
			private_db: PRIVATE_DATABASE
			db_rights : DATABASE_RIGHTS
		do
			private_db ?= session.find_database (database_name)
			if private_db = Void then
				!!private_db.make (database_name)
			end
			if not private_db.is_connected then
				db_rights := local_current_user.group.group_rights_set.rights_for_database (database_name)
				private_db.connect_and_set_rights (db_rights.rights)
			end
		end

end

-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class VIEW_TABLE

feature

	empty: BOOLEAN is
		do
			Result := eiffel_to_versant.empty and versant_to_eiffel.empty
		end

	eiffel_view (a_versant_class: STRING): STRING is
			-- Gives the Eiffel View corresponding to a Versant Class name
		do
			Result := versant_to_eiffel.item (a_versant_class)
			if Result = Void then
				Result := a_versant_class
			end
		end

	versant_class (an_eiffel_view: STRING): STRING is
		do
			Result := eiffel_to_versant.item (an_eiffel_view)
			if Result = Void and not non_creatable_view.has (an_eiffel_view) then
				Result := an_eiffel_view
			end
		end

	is_db_creatable (an_eiffel_view: STRING): BOOLEAN is
		do
			Result := not non_creatable_view.has (an_eiffel_view)
		end

	put (versant_name, eiffel_name: STRING) is
		do
			versant_to_eiffel.put (eiffel_name, versant_name)
			if not non_creatable_view.has (eiffel_name) then
				if not eiffel_to_versant.has (eiffel_name) then
					eiffel_to_versant.put (versant_name, eiffel_name)
				else
					eiffel_to_versant.remove (eiffel_name)
					non_creatable_view.put (versant_name, eiffel_name)
				end
			end
		end

feature {NONE}

	eiffel_to_versant: HASH_TABLE [STRING, STRING] is
			-- Key is the Eiffel name, item is the Versant class
		once
			!!Result.make (17)
		end

	versant_to_eiffel: HASH_TABLE [STRING, STRING] is
			-- Key is the Versant name, item is the Eiffel class
		once
			!!Result.make (17)
		end

	non_creatable_view: HASH_TABLE [STRING, STRING] is
			-- Key is the name of an Eiffel View for which there
			-- is not a "one to one" correspondance with the Versant
			-- Schema
		once
			!!Result.make (17)
		end

end

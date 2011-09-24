-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class REDEFINE_ATTRIB_ACTION

inherit

	DBA_TRANSACTION
	META_PCLASS_SERVER

feature

	error_msg : STRING is "Can't rename attribute";

	cls : META_PCLASS

	old_name : STRING

	cls_name : STRING

	new_attr : PATTRIBUTE

	attr_name : STRING

	att_info : NEW_ATTR_INFO

	set_cls : BOOLEAN is
		do
			cls_name.to_lower
			cls := meta_pclass_by_name (cls_name)
			if cls = Void then
				Result := False
			else
				Result := True
			end
		end

	sub_action is
		local
			temp_name: STRING		
		do
			temp_name := "_old_"
			temp_name.append (old_name)
			cls.rename_attribute (old_name, temp_name)
			cls.add_attribute (new_attr)
			cls.update_pclass
			cls.remove_attribute (temp_name)
			cls.update_pclass
			io.putstring ("Attribute: ");
			attr_name := new_attr.name			
			cls_name.to_upper
			io.putstring (attr_name)
			io.putstring (" in class ")
			io.putstring (cls_name)
			io.putstring(" redefined.%N")
		end

end --class


Case of 
		
	: (Form event code=On Load)
		
		Form.onLoad()
		
	: (Form event code=On Selection Change)
		
		  // the list box reports the clicked row through currentItemSource;
		  // give the status line feedback (Delete index acts on this row)
		var $selected : Object
		$selected:=Form.currentIndex
		If ($selected=Null)
			Form.status:="Select an index in the list"
		Else 
			Form.status:="Selected "+$selected.name+" ("+$selected.typeLabel+")"
		End if 
		
End case 

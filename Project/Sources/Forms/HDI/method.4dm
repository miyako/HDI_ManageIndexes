var $version; $maintext; $subtext : Text
var $r; $format : Text

Case of 
		
	: (Form event code=On Load)
		
		Form.quit:=False
		
		If (Form.info=Null)
			OBJECT SET VISIBLE(*; "labelInfo"; False)
			OBJECT SET VISIBLE(*; "txtInfo"; False)
		End if 
		
		If (Form.blog=Null)
			OBJECT SET VISIBLE(*; "labelBlog"; False)
			OBJECT SET VISIBLE(*; "txtBlog"; False)
		End if 
		
		If (Form.title=Null)
			OBJECT SET VISIBLE(*; "txtTitle"; False)
		Else 
			OBJECT SET TITLE(*; "txtTitle"; Form.title)
		End if 
		
		
		If (Form.minimumVersion=Null)
			OBJECT SET VISIBLE(*; "labelVersion"; False)
			OBJECT SET VISIBLE(*; "TxtVersion"; False)
		Else 
			
			$version:="4D v"+Substring(Form.minimumVersion; 1; 2)
			If (Length(Form.minimumVersion)>2)
				$r:=Substring(Form.minimumVersion; 3; 1)
				If ($r#"0")
					$version:=$version+" R"+$r
					
					// R release: swap the 4D icon for the R icon
					
					$format:=OBJECT Get format(*; "Icon4D")
					$format:=Replace string($format; "4D.png"; "4DR.png")
					OBJECT SET FORMAT(*; "Icon4D"; $format)
					
				End if 
			End if 
			
			$maintext:=Localized string("HDI_TxtVersion")
			$maintext:=Replace string($maintext; "{version}"; $version)
			OBJECT SET TITLE(*; "TxtVersion"; $maintext)
			
			If (Application version<Form.minimumVersion)
				
				Form.quit:=True
				OBJECT SET TITLE(*; "BtnDemo"; Localized string("BtnClose"))
				
				$maintext:=Localized string("HDI_ErrorMainText")
				$maintext:=Replace string($maintext; "{version}"; $version)
				OBJECT SET TITLE(*; "ErrorMainText"; $maintext)
				
				OBJECT SET VISIBLE(*; "ErrorMainText"; True)
				OBJECT SET VISIBLE(*; "ErrorSubText"; True)
				OBJECT SET VISIBLE(*; "White90"; True)
				
			End if 
		End if 
		
		
		If (Form.license#Null) & (Form.quit=False)
			
			If (Not(Is license available(Form.license)))
				
				Form.quit:=True
				OBJECT SET TITLE(*; "BtnDemo"; Localized string("BtnClose"))
				
				Case of 
						
					: (Form.license=4D View license)
						$maintext:=Localized string("ErrorViewProMain")
						$subtext:=Localized string("ErrorViewProSub")
						
					: (Form.license=4D Write license)
						$maintext:=Localized string("ErrorWriteProMain")
						$subtext:=Localized string("ErrorWriteProSub")
						
				End case 
				
				OBJECT SET TITLE(*; "ErrorMainText"; $maintext)
				OBJECT SET TITLE(*; "ErrorSubText"; $subtext)
				
				OBJECT SET VISIBLE(*; "ErrorMainText"; True)
				OBJECT SET VISIBLE(*; "ErrorSubText"; True)
				OBJECT SET VISIBLE(*; "White90"; True)
				
			End if 
			
		End if 
		
End case 

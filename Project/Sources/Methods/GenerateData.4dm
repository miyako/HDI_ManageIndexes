//%attributes = {"invisible":true}
// Generates the demo data on first launch (no-op when the tables are populated).
// The data is fictitious; Documents.embedding is left empty on purpose --
// the vector index is reported by getIndexes() regardless of records.

var $i : Integer

If (ds.Companies.getCount()=0)
	
	var $countries : Collection
	$countries:=New collection("Japan"; "France"; "USA"; "Germany"; "Brazil"; "Australia")
	
	var $companies : Collection
	$companies:=New collection
	
	For ($i; 1; 12)
		$companies.push(New object("companyName"; "Company "+String($i); "country"; $countries[($i-1)%$countries.length]; "code"; "CMP-"+String(1000+$i)))
	End for 
	
	ds.Companies.fromCollection($companies)
	
End if 


If (ds.Persons.getCount()=0)
	
	var $firstNames : Collection
	$firstNames:=New collection("Aiko"; "Bernard"; "Chen"; "Dana"; "Emil"; "Farid"; "Grace"; "Hiroshi"; "Ines"; "Julia")
	
	var $lastNames : Collection
	$lastNames:=New collection("Tanaka"; "Moreau"; "Wang"; "Okafor"; "Rossi"; "Yamada"; "Smith"; "Dubois"; "Nakamura"; "Keller")
	
	var $persons : Collection
	$persons:=New collection
	
	For ($i; 1; 120)
		$persons.push(New object("firstName"; $firstNames[($i-1)%$firstNames.length]; "lastName"; $lastNames[($i-1)%$lastNames.length]; "email"; "user"+String($i)+"@example.com"; "companyID"; ((($i-1)%12)+1); "notes"; Substring("Followed up on the maintenance contract for site "+String($i)+"."; 1; 50)))
	End for 
	
	ds.Persons.fromCollection($persons)
	
End if 


If (ds.Documents.getCount()=0)
	
	var $documents : Collection
	$documents:=New collection
	
	For ($i; 1; 20)
		$documents.push(New object("title"; "Technical note "+String($i)+" -- indexing"; "content"; "Indexing strategy for table "+String($i)+". Covers B-tree maintenance, keyword extraction and storage overhead in production databases."))
	End for 
	
	ds.Documents.fromCollection($documents)
	
End if 

use BibDesk : application "BibDesk"
use scripting additions

tell BibDesk
	activate
	set theDoc to first document
	set originalPub to (selection of theDoc)
	set originalPub to first item of originalPub
	set theAuthors to last name of originalPub's authors
	set len to length of theAuthors
	set searchStr to ""
	repeat with i from 1 to len
		if i > 1 then
			set searchStr to searchStr & "+"
		end if
		set searchStr to searchStr & item i of theAuthors
	end repeat
	set dialogStr to my replaceText("+", " ", searchStr)
	set originalTitle to title of originalPub
	set originalTitle to my replaceText(" ", "+", originalTitle)
	set searchStr to searchStr & "+" & originalTitle
	set crossrefUrl to "https://api.crossref.org/works?query=" & "%22" & searchStr & "%22" & "&rows=5&select=DOI,title,author"
	set theJsonResponse to (do shell script "curl " & quote & crossrefUrl & quote)
	tell application "JSON Helper" to set theJSON to read JSON from theJsonResponse
	set theJSON to |items| of (message of theJSON)
	
	set foundSomething to 0
	repeat with i from 1 to 3
		set theTitle to |title| of item i of theJSON
		set theDOI to doi of item i of theJSON
		--		set theDOI to replaceText("http://dx.doi.org/", "", theDOI)
		display dialog dialogStr & return & (title of originalPub) & return & return & theTitle buttons {"Ok", "Skip"} default button 1
		if the button returned of the result is "OK" then
			set the value of originalPub's field "doi" to theDOI
			set the value of originalPub's field "url" to ("http://dx.doi.org/" & theDOI)
			return
		end if
	end repeat
end tell


on urlEncode(str)
	local str
	try
		return (do shell script "/bin/echo " & quoted form of str & ¬
			" | perl -MURI::Escape -lne 'print uri_escape($_)'")
	on error eMsg number eNum
		error "Can't urlEncode: " & eMsg number eNum
	end try
end urlEncode


on replaceText(find, replace, subject)
	set prevTIDs to text item delimiters of AppleScript
	set text item delimiters of AppleScript to find
	set subject to text items of subject
	set text item delimiters of AppleScript to replace
	set subject to "" & subject
	set text item delimiters of AppleScript to prevTIDs
	return subject
end replaceText

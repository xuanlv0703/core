<cfsetting enablecfoutputonly="yes" />


<cfif not thisTag.HasEndTag>
	<cfabort showerror="skin:loadJS requires an end tag." />
</cfif>

<cfif thistag.executionMode eq "Start">
	<!--- Do Nothing --->
</cfif>

<cfif thistag.executionMode eq "End">
	<cfparam name="attributes.id" default=""><!--- The id of the library that has been registered with the application --->
	<cfparam name="attributes.baseHREF" default=""><!--- The url baseHREF to the JS files--->
	<cfparam name="attributes.lFiles" default=""><!--- The files to include in that baseHREF --->
	<cfparam name="attributes.condition" default=""><!--- the condition to wrap around the style tag --->
	<cfparam name="attributes.prepend" default=""><!--- any JS to prepend to the begining of the script block --->
	<cfparam name="attributes.append" default=""><!--- any JS to append to the end of the script block --->
	<cfparam name="attributes.bCombine" default=""><!--- Should the files be combined into a single cached js file. Passing true/false will override how it was registered. --->
	
	<cfif len(trim(thisTag.generatedContent))>
		<cfset attributes.append = "#attributes.append##thisTag.generatedContent#" />
		<cfset thisTag.generatedContent = "" />
	</cfif>
	
	<cfset stJS = duplicate(attributes) />
	
	<!--- Generate our id based on the baseHREF and files passed in. --->
	<cfif not len(stJS.id)>
		<cfset stJS.id = hash("#stJS.baseHREF##stJS.lFiles#") />
	</cfif>
	
	
	<cfparam name="request.inHead.aJSLibraries" default="#arrayNew(1)#" />
	<cfparam name="request.inHead.stJSLibraries" default="#structNew()#" />
	
	
	<cfif NOT structKeyExists(request.inhead.stJSLibraries, stJS.id)>
		
		<cfif structKeyExists(application.fc.stJSLibraries, stJS.id)>
			<cfif not len(stJS.baseHREF)>
				<cfset stJS.baseHREF = application.fc.stJSLibraries[stJS.id].baseHREF />
			</cfif>
			<cfif not len(stJS.lFiles)>
				<cfset stJS.lFiles = application.fc.stJSLibraries[stJS.id].lFiles />
			</cfif>
			<cfif not len(stJS.condition)>
				<cfset stJS.condition = application.fc.stJSLibraries[stJS.id].condition />
			</cfif>
			<cfif not len(stJS.prepend)>
				<cfset stJS.prepend = application.fc.stJSLibraries[stJS.id].prepend />
			</cfif>
			<cfif not len(stJS.append)>
				<cfset stJS.append = application.fc.stJSLibraries[stJS.id].append />
			</cfif>
			<cfif not isBoolean(stJS.bCombine)>
				<cfset stJS.bCombine = application.fc.stJSLibraries[stJS.id].bCombine />
			</cfif>
		<cfelse>
			<cfif not isBoolean(stJS.bCombine)>
				<cfset stJS.bCombine = true />
			</cfif>
		</cfif>
		
		
		<!--- Add the id to the array to make sure we keep track of the order in which these libraries need to appear. --->
		<cfset arrayAppend(request.inHead.aJSLibraries, stJS.id) />
		
		<!--- Add the JS information to the struct so we will be able to load it all correctly into the header at the end of the request. --->
		<cfset request.inHead.stJSLibraries[stJS.id] = stJS />
	</cfif>
	
	
	<!--- SAVE THIS INFORMATION INTO THE RELEVENT WEBSKINS FOR CACHING --->
	<cfset application.fc.lib.objectbroker.addJSHeadToWebskins(stJS="#stJS#") />
	
	
</cfif>

<cfsetting enablecfoutputonly="no" />
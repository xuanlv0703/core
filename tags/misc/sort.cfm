<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Quicksort tag --->

<cfparam name="attributes.values" />
<cfparam name="attributes.value1" default="value1" />
<cfparam name="attributes.value2" default="value2" />
<cfparam name="attributes.sendback" default="sendback" />
<cfparam name="attributes.result" default="result" />

<cfif not thistag.HasEndTag>
	<cfthrow message="The sort tag must have an end element" />
</cfif>

<cffunction name="initSort" access="public" returntype="boolean" description="Initialises tag and returns true if there are values to sort" output="true">
	
	<cfif isstruct(attributes.values)>
		<cfset thistag.keys = structkeyarray(attributes.values) />
		
		<cfif not structcount(attributes.values)>
			<cfreturn false />
		</cfif>
		
		<cfset thistag.left = 1 />
		<cfset thistag.right = arraylen(thistag.keys) />
		
		<cfreturn true />
	<cfelseif isarray(attributes.values)>
		<cfif not arraylen(attributes.values)>
			<cfreturn false />
		</cfif>
		
		<cfset thistag.left = 1 />
		<cfset thistag.right = arraylen(attributes.values) />
		
		<cfreturn true />
	<cfelse><!--- List --->
		<cfif not len(attributes.values)>
			<cfreturn false />
		</cfif>
		
		<cfset thistag.left = 1 />
		<cfset thistag.right = listlen(attributes.values) />
		
		<cfreturn true />
	</cfif>
</cffunction>

<cffunction name="getValue" access="public" returntype="any" description="Returns the specified element from the values" output="false">
	<cfargument name="index" type="numeric" required="true" hint="The index to return" />	
	
	<cfif isstruct(attributes.values)>
		<cfreturn attributes.values[thistag.keys[arguments.index]] />
	<cfelseif isarray(attributes.values)>
		<cfreturn attributes.values[arguments.index] />
	<cfelse><!--- List --->
		<cfreturn listgetat(attributes.values,arguments.index) />
	</cfif>
</cffunction>

<cffunction name="swapValues" access="public" returntype="void" description="Swaps the specified values" output="false">
	<cfargument name="index1" type="numeric" required="true" hint="The first element to move" />
	<cfargument name="index2" type="numeric" required="true" hint="The second element to move" />
	
	<cfset var temp = "" />
	
	<cfif isstruct(attributes.values)>
		<cfset arrayswap(thistag.keys,arguments.index1,arguments.index2) />
	<cfelseif isarray(attributes.values)>
		<cfset arrayswap(attributes.values,arguments.index1,arguments.index2) />
	<cfelse><!--- List --->
		<cfset temp = listgetat(attributes.values,arguments.index1) />
		<cfset attributes.values = listsetat(attributes.values,arguments.index1,listgetat(attributes.values,arguments.index2)) />
		<cfset attributes.values = listsetat(attributes.values,arguments.index2,temp) />
	</cfif>
</cffunction>

<cffunction name="getResult" access="public" returntype="any" description="Returns the result of the sort" output="false">
	<cfif isstruct(attributes.values)>
		<cfreturn arraytolist(thistag.keys) />
	<cfelseif isarray(attributes.values)>
		<cfreturn attributes.values />
	<cfelse><!--- List --->
		<cfreturn attributes.values />
	</cfif>
</cffunction>

<cfif thistag.ExecutionMode eq "start">
	<cfset thistag.stack = arraynew(1) />
	
	<cfif not initSort()>
		<cfset caller[attributes.result] = getResult() />
		
		<cfexit method="exittag" />
	</cfif>
		
	<cfset thistag.pivot = round((thistag.left + thistag.right) / 2) />
	<cfset thistag.pivotValue = getValue(thistag.pivot) />
	
	<cfset thistag.left2 = thistag.left />
	<cfset thistag.right2 = thistag.right />
	
	<!--- First comparison --->
	<cfset thistag.partition = "left" />
	<cfset caller[attributes.value1] = getValue(thistag.left2) />
	<cfset caller[attributes.value2] = thistag.PivotValue />
	
</cfif>

<cfif thistag.ExecutionMode eq "end">
	<cfif not structkeyexists(caller,attributes.sendback)>
		<cfset stError = structnew() />
		<cfset stError.value1 = caller[attributes.value1] />
		<cfset stError.value2 = caller[attributes.value2] />
		
		<cfthrow object="stError" />
	</cfif>

	<cfif thistag.partition eq "left">
		<cfif caller[attributes.sendback] lt 0>
			<!--- next left partition comparison --->
			<cfset thistag.left2 = thistag.left2 + 1 />
			<cfset caller[attributes.value1] = getValue(thistag.left2) />
			<cfset caller[attributes.value2] = thistag.PivotValue />
			
			<cfset structdelete(caller,attributes.sendback) />
			<cfexit method="loop" />
		<cfelse>
			<!--- break out of left partition loop and do first right partition comparison --->
			<cfset thistag.partition = "right" />
			<cfset caller[attributes.value1] = getValue(thistag.right2) />
			<cfset caller[attributes.value2] = thistag.PivotValue />
			
			<cfset structdelete(caller,attributes.sendback) />
			<cfexit method="loop" />
		</cfif>

	</cfif>
	<cfif thistag.partition eq "right">
		<cfif caller[attributes.sendback] gt 0>
			<!--- next right partition comparison --->
			<cfset thistag.right2 = thistag.right2 - 1 />
			<cfset caller[attributes.value1] = getValue(thistag.right2) />
			<cfset caller[attributes.value2] = thistag.PivotValue />
			
			<cfset structdelete(caller,attributes.sendback) />
			<cfexit method="loop" />
		<cfelse>
			<!--- break out of right partition loop and do any necessary swap --->
			<cfif thistag.left2 lte thistag.right2>
				<cfif thistag.left2 neq thistag.right2>
					<cfset swapValues(thistag.left2,thistag.right2) />
				</cfif>
				<cfset thistag.left2 = thistag.left2 + 1 />
				<cfset thistag.right2 = thistag.right2 - 1 />
			</cfif>
			
			<cfif thistag.left2 lt thistag.right2>
			
				<!--- Go back around to left partition --->
				<cfset thistag.partition = "left" />
				<cfset caller[attributes.value1] = getValue(thistag.left2) />
				<cfset caller[attributes.value2] = thistag.PivotValue />
				
				<cfset structdelete(caller,attributes.sendback) />
				<cfexit method="loop" />
			
			<cfelse>
			
				<!--- Add any partitions --->
				<cfif thistag.right2 - thistag.left gt thistag.right - thistag.left2>
					<cfif thistag.left lt thistag.right2>
						<cfset arrayappend(thistag.stack,thistag.left) />
						<cfset arrayappend(thistag.stack,thistag.right2) />
					</cfif>
					
					<cfset thistag.left = thistag.left2 />
				<cfelse>
					<cfif thistag.left2 lt thistag.right>
						<cfset arrayappend(thistag.stack,thistag.left2) />
						<cfset arrayappend(thistag.stack,thistag.right) />
					</cfif>
					
					<cfset thistag.right = thistag.right2 />
				</cfif>
				
				<cfif thistag.left lt thistag.right>
					
					<cfset thistag.pivot = round((thistag.left+thistag.right) / 2) />
					<cfset thistag.PivotValue = getValue(thistag.pivot) />
					<cfset thistag.left2 = thistag.left />
					<cfset thistag.right2 = thistag.right />
					
					<!--- Start left partition --->
					<cfset thistag.partition = "left" />
					<cfset caller[attributes.value1] = getValue(thistag.left2) />
					<cfset caller[attributes.value2] = thistag.PivotValue />
					
					<cfset structdelete(caller,attributes.sendback) />
					<cfexit method="loop" />
				<cfelseif arraylen(thistag.stack)><!--- Next stack loop --->
				
					<!--- Set up new frame --->
					<cfset thistag.right = thistag.stack[arraylen(thistag.stack)] />
					<cfset arraydeleteat(thistag.stack,arraylen(thistag.stack)) />
					<cfset thistag.left = thistag.stack[arraylen(thistag.stack)] />
					<cfset arraydeleteat(thistag.stack,arraylen(thistag.stack)) />
					
					<cfset thistag.pivot = round((thistag.left+thistag.right) / 2) />
					<cfset thistag.PivotValue = getValue(thistag.pivot) />
					<cfset thistag.left2 = thistag.left />
					<cfset thistag.right2 = thistag.right />
					
					<!--- Start left partition --->
					<cfset thistag.partition = "left" />
					<cfset caller[attributes.value1] = getValue(thistag.left2) />
					<cfset caller[attributes.value2] = thistag.PivotValue />
					
					<cfset structdelete(caller,attributes.sendback) />
					<cfexit method="loop" />
				</cfif>
			</cfif>
		</cfif>
	</cfif>
	
	<cfset caller[attributes.result] = getResult() />
</cfif>

<cfsetting enablecfoutputonly="false" />
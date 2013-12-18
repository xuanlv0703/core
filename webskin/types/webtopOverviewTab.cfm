<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@displayname: Render Webtop Overview Tab --->
<!--- @@description: Renders the Tabs for main information of the overview  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>

<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">


<!--- ENVIRONMENT VARIABLES --->
<cfset stLocal.qTabs = getWebskins(typename=stObj.typename,prefix="webtopOverviewTab") />
<cfset stLocal.stTabs = structnew() />


		
			
			
<!--- WORKFLOW --->
<cfset workflowHTML = application.fapi.getContentType("farWorkflow").renderWorkflow(referenceID="#stobj.objectid#", referenceTypename="#stobj.typename#") />
<cfoutput>#workflowHTML#</cfoutput>

<skin:htmlHead>
<cfoutput>
<style type="text/css">
	.draft {
		float:right;
		outline: none;
		font-weight: bold;
		font-size: 14px;
		padding:5px 10px 5px 10px ;
		text-align:center;
	}
	.pending {
		float:right;
		outline: none;
		font-weight: bold;
		font-size: 14px;
		padding:5px 10px 5px 10px ;
		text-align:center;
	}
	.approved {
		float:right;
		outline: none;
		font-weight: bold;
		font-size: 14px;
		padding:5px 10px 5px 10px ;
		text-align:center;
	}
	
	.draft a,
	.pending a,
	.approved a {
		background:transparent;
		text-shadow: none;
		color:inherit;
	}
	
	.draft a:hover,
	.pending a:hover,
	.approved a:hover {
		color:inherit;
	}

	span.btn a {
		color: white;
		text-decoration: none;
	}
	span.btn a i.fa {
		margin-right: 6px;
		margin-left: 0;
	}

</style>
</cfoutput>
</skin:htmlHead>

<cfoutput>

	<!--- CONTENT ITEM STATUS --->
	<cfif structKeyExists(stobj,"status")>			
		
		<cfswitch expression="#stobj.status#">
		<cfcase value="draft">
			<cfoutput>
			<div class="pull-right" style="text-align:center">
				<div class="draft alert alert-error pull-right" style="margin-top:0;margin-bottom:5px;">
					<div>DRAFT</div>
					<div style="font-size:11px;">Last updated <span title="#dateFormat(stobj.datetimelastupdated,'dd mmm yyyy')# #timeFormat(stobj.datetimelastupdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.datetimelastupdated)#</span></div>
					<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
						<span class="btn btn-primary" style="display:inline;font-size:11px;"><skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="typename=#stObj.typename#&versionID=#stobj.versionID#"><i class="fa fa-random"></i>Show approved version</skin:buildLink></span>
					</cfif>
				</div>
			</div>
			</cfoutput>
		</cfcase>
		<cfcase value="pending">
			<cfoutput>
			<div class="pull-right" style="text-align:center">
				<div class="pending alert alert-warning pull-right" style="margin-top:0;margin-bottom:5px;">
					<div>PENDING</div>
					<div style="font-size:11px;">Awaiting approval since <span title="#dateFormat(stobj.datetimelastupdated,'dd mmm yyyy')# #timeFormat(stobj.datetimelastupdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.datetimelastupdated)#</span></div>
					<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
						<span class="btn btn-primary" style="display:inline;font-size:11px;"><skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="typename=#stObj.typename#&versionID=#stobj.versionID#"><i class="fa fa-random"></i>Show approved version</skin:buildLink></span>
					</cfif>
				</div>
			</div>
			</cfoutput>
		</cfcase>
		<cfcase value="approved">
			<cfoutput>
			<div class="pull-right" style="text-align:center">
				<div class="approved alert alert-success" style="margin-top:0;margin-bottom:5px;">
					<div>APPROVED</div> 
					<div style="font-size:11px;">Last approved <span title="#dateFormat(stobj.datetimelastupdated,'dd mmm yyyy')# #timeFormat(stobj.datetimelastupdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.datetimelastupdated)#</span></div>
					<cfif structKeyExists(stobj,"versionID") AND structKeyExists(stobj,"status") AND stobj.status EQ "approved">
						<cfset qDraft = application.factory.oVersioning.checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
						<cfif qDraft.recordcount>
							<span class="btn btn-primary" style="display:inline;font-size:11px;"><skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="typename=#stObj.typename#&versionID=#qDraft.objectid#"><i class="fa fa-random"></i>Show #qDraft.status# version</skin:buildLink></span>
						</cfif>
					</cfif>
				</div>
			</div>
			</cfoutput>
		</cfcase>
		</cfswitch>
	
	</cfif>	

	<h1>
		<cfif len(application.stCOAPI[stobj.typename].icon)>
			<i class="fa #application.stCOAPI[stobj.typename].icon#"></i>
		<cfelse>
			<i class="fa fa-file"></i>
		</cfif>
		#stobj.label#
	</h1>

</cfoutput>

			
			
		<cfset tabID = "directory#replace(stObj.objectid,'-','','ALL')#" />
		<admin:tabs id="#tabID#">
			<cfoutput>  
			<admin:tabItem id="tabs-summary" title="General">
				<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="webtopOverviewSummary" />
			</admin:tabItem>      
			
			<cfif application.fapi.getContentTypeMetadata(typename="#stobj.typename#", md="bFriendly", default="false")>
				<admin:tabItem id="SEO">
					<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="webtopOverviewSEO" />
				</admin:tabItem>     
			</cfif>	
		
			<cfloop query="stLocal.qTabs">
				<cfif stLocal.qTabs.methodname neq "webtopOverviewTab" and isdefined("application.stCOAPI.#stObj.typename#.stWebskins.#stLocal.qTabs.methodname#.displayname")>
					<admin:tabItem id="#tabID#-custom-#stLocal.qTabs.currentRow#" 
									title="#application.stCOAPI[stObj.typename].stWebskins[stLocal.qTabs.methodname].displayname#">
								
							<skin:view typename="#stobj.typename#" objectid="#stObj.objectid#" webskin="#stLocal.qTabs.methodname#">
					
					</admin:tabItem>
				</cfif>
			</cfloop>
			 </cfoutput>
		</admin:tabs>
	
<cfsetting enablecfoutputonly="false">
		
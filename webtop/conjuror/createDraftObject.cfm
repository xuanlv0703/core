<!--- 
merge of ../admin/navajo/createDraftObject.cfm and ../tags/navajo/createDraftObject.cfm
 --->
 <cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4" />
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj" />
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />

<cfprocessingDirective pageencoding="utf-8">
<!--- createDraftObject.cfm 
Creates a draft object
--->

<cfsetting enablecfoutputonly="no">
<cfoutput>
	<link rel="stylesheet" type="text/css" href="#application.url.farcry#/navajo/navajo_popup.css">
</cfoutput>


<cfparam name="url.objectId" default="">

<cfif len(url.objectId)>
	<!--- Get this object so we can duplicate it --->
	<q4:contentobjectget objectid="#url.objectId#" bactiveonly="False" r_stobject="stObject">
	
	<cfscript>
		stProps=structCopy(stObject);
		stProps.objectid = application.fc.utils.createJavaUUID();
		stProps.lastupdatedby = application.security.getCurrentUserID();
		stProps.datetimelastupdated = Now();
		stProps.createdby = application.security.getCurrentUserID();
		stProps.datetimecreated = Now();
		// dmHTML specific props
		//stProps.displayMethod = "display";
		stProps.status = "draft";
		//dmNews specific props
		stProps.versionID = URL.objectID;

		// create the new OBJECT 
		oType = createobject("component", application.types[stProps.TypeName].typePath);
		stNewObj = oType.createData(stProperties=stProps);
		NewObjId = stNewObj.objectid;

		//this will copy containers and there rules from live object to draft
		oCon = createobject("component","#application.packagepath#.rules.container");
		oCon.copyContainers(stObject.objectid,stProps.objectid);
		
		//this will copy categories from live object to draft
		oCategory = createobject("component","#application.packagepath#.farcry.category");
		oCategory.copyCategories(stObject.objectid,stProps.objectid);
	</cfscript>
	
	<farcry:logevent object="#url.objectid#" type="coapi" event="createDraftObject" notes="Draft object created" />

	<cfoutput>
	<script>
		window.location="#application.url.farcry#/navajo/edit.cfm?objectId=#NewObjID#&type=#stProps.typename#<cfif isDefined('url.finishUrl')>&finishUrl=#url.finishUrl#</cfif><cfif isDefined('url.iframe')>&iframe=#url.iframe#</cfif>";
	</script>
	</cfoutput>
</cfif>


	  
<cfsetting enablecfoutputonly="No">
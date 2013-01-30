<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />

<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
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
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/widgets/dateSelector.cfm,v 1.13.2.1 2006/01/26 11:36:12 geoff Exp $
$Author: geoff $
$Date: 2006/01/26 11:36:12 $
$Name: milestone_3-0-1 $
$Revision: 1.13.2.1 $

|| DESCRIPTION || 
$Description: date selection widget $
$TODO: needs major overhaul by the looks! Claiming ownership... GB 20050126 
issues include.. 
 - toggle to turn date off rooted, defaults to now() when re-edited
 - date picker control just plain nasty
 - dates not within control range default to now() uber nasty
 - caller scope references need to be removed
 - crack like #attributes.fieldNamePrefix#Date needs to be replaced with just the property name
 - JS needs to be put in the HTML/HEAD of document
$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$

|| ATTRIBUTES ||
$in: attribute -- description $
--->
<cfparam name="attributes.fieldNamePrefix" default="">
<cfparam name="caller.output" default="">
<cfparam name="attributes.fieldLabel" default="#attributes.fieldNamePrefix# Date:">
<cfparam name="attributes.bDateToggle" default="0">
<cfparam name="attributes.bShowTime" default="1">
<cfparam name="attributes.fieldValue" default="#now()#">
<cfparam name="attributes.startYear" default="#year(dateadd('yyyy',-3,now()))#">
<cfparam name="attributes.endYear" default="#year(dateadd('yyyy',3,now()))#">

<cfset localeMonths = application.thisCalendar.getMonths(session.dmProfile.locale)>
<cfset output = caller.output>

<!--- interim crack in here to guess at proper fieldname GB --->
<cfif isDefined("output.#attributes.fieldNamePrefix#Date")>
	<cfset attributes.fieldname=evaluate("output.#attributes.fieldNamePrefix#Date")>
</cfif>

<!--- set the range limits for years --->
<cfif isDefined("attributes.fieldname") AND isDate(attributes.fieldname) AND year(attributes.fieldname) lte attributes.startYear>
	<cfset startYear = year(attributes.fieldname)-3>
<cfelse>
	<cfset startYear = attributes.startYear>
</cfif>
<cfset endYear = attributes.endYear>


<!--- set the default expiry date to now() --->
<cfset defaultExpiryDate = now()>

<cfif IsStruct(output) AND NOT StructIsEmpty(caller.output)>
	<cfif isDate(output["#attributes.fieldNamePrefix#Date"])>
		<cfset selectedDate = output["#attributes.fieldNamePrefix#Date"]>
	<cfelse>
		<cfset selectedDate = Now()>
	</cfif>
	
	<!--- defaults the expiry date if dmnews/dmevents --->
	<cfif output.typename EQ "dmevent">
		<cfset defaultExpiryDate = DateAdd(application.config.general.eventsExpiryType,application.config.general.eventsExpiry,defaultExpiryDate)>
	<cfelseif output.typename EQ "dmnews">
		<cfset defaultExpiryDate = DateAdd(application.config.general.newsExpiryType,application.config.general.newsExpiry,defaultExpiryDate)>
	</cfif>
<cfelse>
	<cfset selectedDate = attributes.fieldValue>
</cfif>

<cfset expiry_Year = year(defaultExpiryDate)>
<cfset expiry_Month = month(defaultExpiryDate)>
<cfset expiry_Day = day(defaultExpiryDate)>

<cfset fieldNamePrefix = attributes.fieldNamePrefix>
<cfset fieldLabel = attributes.fieldLabel>
<cfset tglLinkNo = "Set an #fieldNamePrefix# date">
<cfset tglLinkYes = "Remove #fieldNamePrefix# date">

<cfif fieldNamePrefix NEQ "">
<cfoutput>
<span class="f-multiselect-wrap" style="position:relative;padding-bottom: 2em;margin-bottom: 1em">
	<b>#fieldLabel#</b>
	<cfif attributes.bDateToggle EQ 1>
		<div id="pretext_#fieldNamePrefix#" style="position:absolute; bottom:2em;left:135px;font-weight: bold"><cfif Year(selectedDate) EQ 2050>No #fieldNamePrefix# date set |</cfif></div>
		<a href="##" style="position:absolute; bottom:0;left:135px;" onclick="return doToggle#fieldNamePrefix#();"><div id="linkText_#fieldNamePrefix#"><cfif Year(selectedDate) EQ 2050>#tglLinkNo#<cfelse>#tglLinkYes#</cfif></div></a>
	</cfif>

<cfif attributes.bDateToggle>
	<span id="tgl#fieldNamePrefix#"<cfif Year(selectedDate) EQ 2050> style="visibility:hidden;"</cfif>>
</cfif>
	<select name="#fieldNamePrefix#Day" id="#fieldNamePrefix#Day"><cfloop from="1" to="31" index="i">
		<option value="#i#"<cfif Day(selectedDate) EQ i> selected="selected"</cfif>>#i#</option></cfloop>
	</select>	

	<select name="#fieldNamePrefix#Month" id="#fieldNamePrefix#Month"><cfloop from="1" to="12" index="i">
		<option value="#i#"<cfif Month(selectedDate) EQ i> selected="selected"</cfif>>#localeMonths[i]#</option></cfloop>
	</select>

	<select name="#fieldNamePrefix#Year" id="#fieldNamePrefix#Year"><cfloop from="#startYear#" to="#endYear#" index="i">
		<option value="#i#"<cfif Year(selectedDate) EQ i> selected="selected"</cfif>>#i#</option></cfloop>
	</select><br />
	<cfif attributes.bShowTime>
	<select name="#fieldNamePrefix#Hour" class="f-hours"><cfloop from="0" to="23" index="i">
		<option value="#i#"<cfif Hour(selectedDate) EQ i> selected="selected"</cfif>>#i# #application.rb.getResource("hrs")#</option></cfloop>
	</select>

	<select name="#fieldNamePrefix#Minutes" class="f-mins"><cfloop from="0" to="45" index="i" step="15">
		<option value="#i#"<cfif Minute(selectedDate) EQ i> selected="selected"</cfif>>#i# #application.rb.getResource("mins")#</option></cfloop>
	</select><br /></cfif>
	<cfif attributes.bDateToggle>
	</span></cfif>
</span>
	<cfif attributes.bDateToggle EQ 1>
<input type="hidden" id="no#fieldNamePrefix#" name="no#fieldNamePrefix#" value="<cfif Year(selectedDate) EQ 2050>1<cfelse>0</cfif>">
<script type="text/javascript">
function doToggle#fieldNamePrefix#(){
	objTgl = document.getElementById('tgl#fieldNamePrefix#');
	objHidden = document.getElementById("no#fieldNamePrefix#");
	d = document.getElementById('linkText_#fieldNamePrefix#');
	e = document.getElementById('pretext_#fieldNamePrefix#');

	objYear = document.getElementById('#fieldNamePrefix#Year');
	objMonth = document.getElementById('#fieldNamePrefix#Month');
	objDay = document.getElementById('#fieldNamePrefix#Day');

	if(objTgl.style.visibility == "hidden"){
		objTgl.style.visibility = "visible";
		d.innerHTML = "#tglLinkYes#";
	 	e.innerHTML = "";
		objHidden.value = 0;

		// default the expiry year
		for(i=0; i<objYear.length; i++){
			if(objYear[i].value == #expiry_Year#){
				objYear[i].selected = true;
				break;
			}
		}

		// default the expiry month
		for(i=0; i<objMonth.length; i++){
			if(objMonth[i].value == #expiry_Month#){
				objMonth[i].selected = true;
				break;
			}
		}
		
		// default the expiry day
		for(i=0; i<objDay.length; i++){
			if(objDay[i].value == #expiry_Day#){
				objDay[i].selected = true;
				break;
			}
		}
	}
	else {
		objTgl.style.visibility = "hidden";
		d.innerHTML = "#tglLinkNo#";
		e.innerHTML = "No #fieldNamePrefix# date set |";
		objHidden.value = 1;
	}
	return false;
}
</script>
	</cfif>
</cfoutput>
</cfif> <!--- /fieldNamePrefix NEQ "" --->
<cfsetting enablecfoutputonly="false">
<cfparam name="attributes.package" default="">
<cfparam name="attributes.file">

<!-- ========= START OF NAVBAR ======= -->
<A NAME="navbar_top"><!-- --></A>
<A HREF="#skip-navbar_top" title="Skip navigation links"></A>
<TABLE BORDER="0" WIDTH="100%" CELLPADDING="1" CELLSPACING="0" SUMMARY="">
<TR>
<TD COLSPAN=2 BGCOLOR="#EEEEFF" CLASS="NavBarCell1">
<A NAME="navbar_top_firstrow"><!-- --></A>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="3" SUMMARY="">
  <TR ALIGN="center" VALIGN="top">
	<cfset root = RepeatString('../', ListLen(attributes.package, ".")) />

  <cfif attributes.page eq "Overview">
	<TD BGCOLOR="#FFFFFF" CLASS="NavBarCell1Rev"> &nbsp;<FONT CLASS="NavBarFont1Rev"><B>Overview</B></FONT>&nbsp;</TD>
  <cfelse>
	<cfoutput>
	<TD BGCOLOR="##EEEEFF" CLASS="NavBarCell1">    <A HREF="#root#overview-summary.html"><FONT CLASS="NavBarFont1"><B>Overview</B></FONT></A>&nbsp;</TD>
	</cfoutput>
  </cfif>

  <cfif attributes.page eq "Package">
	<TD BGCOLOR="#FFFFFF" CLASS="NavBarCell1Rev"> &nbsp;<FONT CLASS="NavBarFont1Rev"><B>Package</B></FONT>&nbsp;</TD>
  <cfelseif attributes.page eq "Class">
	<TD BGCOLOR="##EEEEFF" CLASS="NavBarCell1">    <A HREF="package-summary.html"><FONT CLASS="NavBarFont1"><B>Package</B></FONT></A>&nbsp;</TD>
  <cfelse>
	<TD BGCOLOR="#EEEEFF" CLASS="NavBarCell1">    <FONT CLASS="NavBarFont1">Package</FONT>&nbsp;</TD>
  </cfif>

	<cfif attributes.page eq "Class">
		<TD BGCOLOR="#FFFFFF" CLASS="NavBarCell1Rev"> &nbsp;<FONT CLASS="NavBarFont1Rev"><B>Class</B></FONT>&nbsp;</TD>
	<cfelse>
	<TD BGCOLOR="#EEEEFF" CLASS="NavBarCell1">    <FONT CLASS="NavBarFont1">Class</FONT>&nbsp;</TD>
	</cfif>

  <!---
  <TD BGCOLOR="#EEEEFF" CLASS="NavBarCell1">    <FONT CLASS="NavBarFont1">Package</FONT>&nbsp;</TD>
  <TD BGCOLOR="#EEEEFF" CLASS="NavBarCell1">    <A HREF="overview-tree.html"><FONT CLASS="NavBarFont1"><B>Tree</B></FONT></A>&nbsp;</TD>
  <TD BGCOLOR="#EEEEFF" CLASS="NavBarCell1">    <A HREF="deprecated-list.html"><FONT CLASS="NavBarFont1"><B>Deprecated</B></FONT></A>&nbsp;</TD>
  <TD BGCOLOR="#EEEEFF" CLASS="NavBarCell1">    <A HREF="index-all.html"><FONT CLASS="NavBarFont1"><B>Index</B></FONT></A>&nbsp;</TD>
  --->

  </TR>
</TABLE>
</TD>
<TD ALIGN="right" VALIGN="top" ROWSPAN=3><EM>
<cfoutput>
#attributes.projectTitle#</EM>
</cfoutput>
</TD>
</TR>

<TR>

<TD BGCOLOR="white" CLASS="NavBarCell2"><FONT SIZE="-2">
	<cfoutput>
	  <A HREF="#root#index.html?#attributes.file#.html" target="_top"><B>FRAMES</B></A>  &nbsp;
	</cfoutput>
</FONT></TD>

</TR>
</TABLE>
<A NAME="skip-navbar_top"></A>
<!-- ========= END OF NAVBAR ========= -->